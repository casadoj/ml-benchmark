#!/usr/bin/env python
"""
Compute the benchmark metrics of a model with `ml-eval benchmark` and aggregate
them across domains.

Usage
-----
    ./evaluate.py --config-file config.yaml
    ./evaluate.py -c config.yaml
    ./evaluate.py -c config.yaml --aggregate-only
    ./evaluate.py -c config.yaml --keep-domain-files
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

import numpy as np
import yaml

from config import DEFAULT_CONFIG_FILE, Config

ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
FIGURES_DIR = ROOT_DIR / "figures"


def quadratic_mean(values: np.ndarray) -> float:
    """
    Compute the quadratic mean (root mean square) of an array.

    Parameters
    ----------
    values : np.ndarray
        Values to aggregate.

    Returns
    -------
    float
        sqrt(mean(values**2)); NaN if any value is NaN.
    """
    return float(np.sqrt(np.mean(np.square(values))))


# metric -> aggregation across domains
AGGREGATION = {
    "clim_mean": np.mean,
    "iav": np.mean,
    "lhd": quadratic_mean,
    "pss": np.mean,
    "ralsd": np.mean,
    "rmse": quadratic_mean,
    "rx1day": np.mean,
    "sdii": np.mean,
    "txx": np.mean,
}


def parse_args() -> argparse.Namespace:
    """
    Parse the command-line arguments.

    Returns
    -------
    argparse.Namespace
        Arguments, with the attributes `config_file`, `aggregate_only` and
        `keep_domain_files`.
    """
    parser = argparse.ArgumentParser(
        description="Compute the benchmark metrics of a model."
    )
    parser.add_argument(
        "-c",
        "--config-file",
        type=Path,
        default=DEFAULT_CONFIG_FILE,
        help="YAML configuration file (default: %(default)s)",
    )
    parser.add_argument(
        "--aggregate-only",
        action="store_true",
        help="skip `ml-eval` and only rebuild the summaries from the domain files",
    )
    parser.add_argument(
        "--keep-domain-files",
        action="store_true",
        help="keep the per-domain metric files after writing the summary "
        "(by default they are deleted)",
    )
    return parser.parse_args()


def _to_json_float(x: float) -> float | None:
    """Convert a scalar to a JSON-safe float (NaN -> None, written as null)."""
    x = float(x)
    return None if np.isnan(x) else x


def evaluate(config: Config) -> int:
    """
    Run `ml-eval benchmark` for every case defined in the configuration.

    Cases whose reference or prediction file is missing are skipped, and a failed
    `ml-eval` call does not stop the remaining cases.

    Parameters
    ----------
    config : Config
        Model, domains, experiments and variables to evaluate.

    Returns
    -------
    int
        Number of failed `ml-eval` calls.
    """
    with open(FIGURES_DIR / "datasets.yaml") as f:
        dataset_mapping = yaml.safe_load(f)

    with open(FIGURES_DIR / "experiments.yaml") as f:
        experiment_mapping = yaml.safe_load(f)

    n_failed = 0
    model_dir = DATA_DIR / config.model
    for domain in config.domains:
        for train_exp in config.experiments:

            for test_exp, attrs in experiment_mapping[train_exp].items():
                horizon, period, case = attrs["horizon"], attrs["period"], attrs["case"]
                forcing = dataset_mapping[domain]["train_gcm"]

                print(f'[evaluate] {train_exp} | {test_exp} | {domain} |')

                # x0: reference file
                x0 = (
                    DATA_DIR / "target" / f"{domain}_domain" / "test" / horizon
                    / "target" / f"pr_tasmax_{forcing}_{period}.nc"
                )
                if not x0.is_file():
                    print(f"[evaluate] SKIP: reference file not found: {x0}")
                    continue
                # x1: prediction file
                x1 = (
                    model_dir / "predictions" / f"{domain}_Domain" / train_exp / horizon
                    / case / f"Predictions_pr_tasmax_{forcing}_{period}.nc"
                )
                if not x1.is_file():
                    print(f"[evaluate] SKIP: prediction file not found: {x1}")
                    continue

                # output directory
                out_dir = model_dir / "evaluation" / train_exp / test_exp
                out_dir.mkdir(parents=True, exist_ok=True)

                # compute benchmark metrics for each variable
                for var in config.variables:
                    out_file = out_dir / f"metrics_{var}_{domain}.json"
                    cmd = [
                        "ml-eval", "benchmark",
                        "--x0", str(x0),
                        "--x1", str(x1),
                        "--var", var,
                        "--output", str(out_file),
                    ]
                    result = subprocess.run(cmd)
                    if result.returncode != 0:
                        print(f"[evaluate] FAILED ({result.returncode}): {' '.join(cmd)}")
                        n_failed += 1

    return n_failed


def aggregate(config: Config, keep_domain_files: bool = False) -> None:
    """
    Aggregate the per-domain metrics into one summary per train/test experiment.

    For every train/test experiment pair, reads `metrics_{var}_{domain}.json` and
    writes `metrics_summary.json` in the same directory, holding for each variable
    and metric the aggregation rule, the aggregate and the per-domain values.

    Missing data are not dropped: a NaN domain value makes the aggregate NaN
    (null in the JSON). Domains listed in the configuration without a metric file
    are reported, and the aggregate covers only the domains found (listed in the
    summary under `domains`).

    Parameters
    ----------
    config : Config
        Model, domains, experiments and variables to aggregate.
    keep_domain_files : bool, default False
        Keep the per-domain metric files after the summary is written. If False,
        they are deleted, and a later `--aggregate-only` run has nothing to read
        for that experiment.
    """
    with open(FIGURES_DIR / "experiments.yaml") as f:
        experiment_mapping = yaml.safe_load(f)

    model_dir = DATA_DIR / config.model
    for train_exp in config.experiments:
        for test_exp in experiment_mapping[train_exp]:
            out_dir = model_dir / "evaluation" / train_exp / test_exp

            summary = {
                "model": config.model,
                "train_experiment": train_exp,
                "test_experiment": test_exp,
                "variables": {},
            }
            src_files = []
            for var in config.variables:
                # read domain-specific metrics
                results = {}
                for domain in config.domains:
                    file = out_dir / f"metrics_{var}_{domain}.json"
                    if not file.is_file():
                        print(f"[aggregate] MISSING: {file}")
                        continue
                    with open(file) as f:
                        results[domain] = json.load(f)
                    src_files.append(file)
                if not results:
                    continue
                domains = list(results)

                # aggregate metrics across domains
                metric_names = dict.fromkeys(
                    m for values in results.values() for m in values
                )
                metrics = {}
                for metric in metric_names:
                    func = AGGREGATION.get(metric)
                    if func is None:
                        print(f"[aggregate]SKIP: no aggregation rule for {var} metric {metric!r}")
                        continue
                    values = np.array(
                        [results[d].get(metric, np.nan) for d in domains], dtype=float
                    )
                    metrics[metric] = {
                        "aggregation": func.__name__,
                        "aggregate": _to_json_float(func(values)),
                        "domains": {
                            d: _to_json_float(v) for d, v in zip(domains, values)
                        },
                    }
                summary["variables"][var] = metrics

            if not summary["variables"]:
                print(f"[aggregate]SKIP: no metric files in {out_dir}")
                continue

            # export
            summary_file = out_dir / "metrics_summary.json"
            with open(summary_file, "w") as f:
                json.dump(summary, f, indent=2)
            print(f"[aggregate] Summary saved: {summary_file}")

            # only after the summary is safely written
            if not keep_domain_files:
                for file in src_files:
                    file.unlink()


def main() -> None:
    """Read the configuration file, evaluate the model and aggregate the metrics."""
    # keep prints in order with the output of `ml-eval` when logging to a file
    sys.stdout.reconfigure(line_buffering=True)

    args = parse_args()
    config = Config.from_yaml(args.config_file)
    n_failed = 0 if args.aggregate_only else evaluate(config)
    aggregate(config, keep_domain_files=args.keep_domain_files)
    if n_failed > 0:
        sys.exit(f"{n_failed} evaluation(s) failed")


if __name__ == "__main__":
    main()
