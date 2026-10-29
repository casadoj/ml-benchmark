"""Helpers shared by the figure ``plot.sh`` scripts.

The ``plot.sh`` scripts embed a small Python program. Anything that is not
specific to one figure lives here, so a fix is made once. The scripts find this
module because they put ``figures/`` on ``PYTHONPATH``.
"""

from __future__ import annotations

import os
from pathlib import Path

import numpy as np
import pandas as pd


def run_dir(
    data_dir: Path,
    sim: str,
    domain: str,
    train_exp: str,
    rcm: str,
    train_gcm: str,
    dataset: str,
    period: str,
    season: str,
) -> Path:
    """Return one run's season directory; viz appends <var> to it.

    Parameters
    ----------
    data_dir : pathlib.Path
        Root of the benchmark data (``data/``).
    sim : str
        Simulation (model) directory name.
    domain : str
        Domain name without the ``_Domain`` suffix (e.g. ``"ALPS"``).
    train_exp : str
        Training experiment (e.g. ``"ESD_pseudo_reality"``).
    rcm : str
        Regional climate model name.
    train_gcm : str
        GCM used for training.
    dataset : str
        GCM of the evaluated predictions (``train_gcm`` or the test GCM).
    period : str
        Evaluation period, e.g. ``"1981-2000"``.
    season : str
        Season of the metrics (e.g. ``"annual"``).

    Returns
    -------
    pathlib.Path
        Directory ``<data_dir>/<sim>/evaluation/<domain>_Domain/<train_exp>/
        <rcm>_<train_gcm>_<dataset>_<period>/<season>``.
    """
    stem = f"{rcm}_{train_gcm}_{dataset}_{period}"
    return data_dir / sim / "evaluation" / f"{domain}_Domain" / train_exp / stem / season


def keep(
    paths: dict[str, dict[str, Path]],
    domains: list[str],
    var: str,
) -> dict[str, dict[str, Path]]:
    """Keep only models with metric directories for every requested domain.

    Models with a missing domain are reported on stdout and dropped.

    Parameters
    ----------
    paths : dict of {str: dict of {str: pathlib.Path}}
        For each model and domain, the run's season directory.
    domains : list of str
        Domains that must all be present.
    var : str
        Variable whose sub-directory (``<path>/<var>``) must exist.

    Returns
    -------
    dict of {str: dict of {str: pathlib.Path}}
        The subset of ``paths`` that is complete.
    """
    out = {}
    for model, path_dict in paths.items():
        missing = [
            domain
            for domain in domains
            if domain not in path_dict or not (path_dict[domain] / var).is_dir()
        ]
        if missing:
            print(
                f"[plot] SKIP {model}: {var} metrics missing for "
                f"domain(s) {', '.join(missing)}"
            )
            continue
        out[model] = path_dict
    return out


def missing_metrics(
    results: dict[str, dict[str, tuple[float, float]]],
    metrics: list[str],
) -> dict[str, list[str]]:
    """Return the metrics with no finite mean in each domain.

    Parameters
    ----------
    results : dict of {str: dict of {str: tuple of float}}
        For each domain and metric, a tuple of the mean and coefficient of
        variation (CV).
    metrics : list of str
        Metrics that are required.

    Returns
    -------
    dict of {str: list of str}
        For each domain with problems, the missing or non-finite metrics.
        Domains with no problems are omitted.
    """
    missing = {}
    for domain, domain_results in results.items():
        missing[domain] = [
            metric
            for metric in metrics
            if metric not in domain_results
            or not np.isfinite(domain_results[metric][0])
        ]
    return {domain: metrics for domain, metrics in missing.items() if metrics}


def aggregate_domains(
    results: dict[str, dict[str, tuple[float, float]]],
) -> dict[str, tuple[float, float]]:
    """Aggregate metric means and CV (coefficient of variation) across domains.

    Parameters
    ----------
    results : dict of {str: dict of {str: tuple of float}}
        For each domain and metric, a tuple of the mean and coefficient of
        variation (CV).

    Returns
    -------
    dict of {str: tuple of float}
        Mapping from metric name to the aggregated (mean, CV) across domains.
    """
    if not results:
        return {}
    domains = list(results.keys())
    metrics = results[domains[0]].keys()

    aggregated = {}
    for metric in metrics:
        # extract statistics across domains
        mus = np.array([results[domain][metric][0] for domain in domains])
        cvs = np.array([results[domain][metric][1] for domain in domains])
        sigmas = cvs * mus

        # compute across-domain statistics
        mu_global = np.mean(mus)
        var_intra = np.mean(sigmas**2)
        var_inter = np.mean((mus - mu_global) ** 2)
        sigma_global = np.sqrt(var_intra + var_inter)
        cv_global = sigma_global / mu_global if mu_global != 0 else np.nan

        aggregated[metric] = (mu_global.item(), cv_global.item())

    return aggregated


def save_var_skill_scorecard(
    per_model: dict[str, dict[str, tuple[float, float]]],
    filename: str | None = None,
) -> None | pd.DataFrame:
    """Create and optionally export the aggregated metric table.

    Parameters
    ----------
    per_model : dict of {str: dict of {str: tuple of float}}
        Performance metrics for each model.
    filename : str, optional
        If provided, save the table to this path; otherwise return it.

    Returns
    -------
    pandas.DataFrame or None
        If ``filename`` is not provided, a table (models x metrics)
        summarizing the aggregated metrics; otherwise None.
    """
    df = pd.DataFrame.from_dict(
        {
            model: {
                metric: value[0] if isinstance(value, tuple) else value
                for metric, value in metrics.items()
            }
            for model, metrics in per_model.items()
        },
        orient="index",
    )
    df.index.name = "model"
    df.columns.name = "metric"
    if filename is not None:
        df.to_csv(filename)
        return None
    return df


def apply_model_override(
    models: list[tuple[str, str, str]],
) -> list[tuple[str, str, str]]:
    """Replace a figure's model roster with the one in ``PLOT_MODELS``.

    ``plot_master.sh`` can impose ONE roster on every figure of a sweep by
    exporting ``PLOT_MODELS``: whitespace-separated entries, each either a LABEL
    already in ``models`` (its simulation dir and checkpoint tag are reused) or
    an explicit "LABEL,SIMDIR,CKPT" for a model this figure does not know yet.
    It REPLACES ``models``, in the order given. Unset -> ``models`` is returned
    unchanged, so running a figure script alone behaves as before.

    Parameters
    ----------
    models : list of tuple of str
        The figure's own roster, as (label, simulation dir, checkpoint tag).

    Returns
    -------
    list of tuple of str
        The roster to use, in the same (label, simulation dir, checkpoint tag)
        form.

    Raises
    ------
    SystemExit
        If an entry has a number of comma-separated parts other than 1 or 3.
    """
    override = os.environ.get("PLOT_MODELS", "").split()
    if not override:
        return models

    known = {m[0]: m for m in models}
    out = []
    for entry in override:
        parts = entry.split(",")
        if len(parts) == 3:
            out.append(tuple(parts))
        elif len(parts) != 1:
            raise SystemExit(
                f"[plot] PLOT_MODELS: {entry!r} is neither a label nor "
                '"LABEL,SIMDIR,CKPT".'
            )
        elif entry in known:
            out.append(known[entry])
        else:
            print(
                f"[plot] PLOT_MODELS: {entry} is not one of this figure's "
                f"models -- assuming sim dir and checkpoint tag {entry!r}"
            )
            out.append((entry, entry, entry))
    print(f"[plot] PLOT_MODELS: {' '.join(m[0] for m in out)}")
    return out
