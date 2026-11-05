#!/usr/bin/env python
"""
Build the scoreboard tables of README.md from the models' metric summaries.

Reads `data/<MODEL>/evaluation/<TRAIN_EXP>/<TEST_EXP>/metrics_summary.json` (written
by `evaluate.py`) for every model and writes one HTML table per variable (rows =
models, columns = train/test experiments x metrics) between the markers
`<!-- SCOREBOARD:START -->` and `<!-- SCOREBOARD:END -->` in README.md.

Usage
-----
    ./scoreboard.py            # update README.md in place
    ./scoreboard.py --print    # print the tables to stdout instead
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import yaml

ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
BENCHMARK_DIR = ROOT_DIR / "benchmark"
README_FILE = ROOT_DIR / "README.md"
SUMMARY_FILE = "metrics_summary.json"
METADATA_FILE = "metadata.yaml"
OROG_SUFFIX = "-orog"
START_MARKER = "<!-- SCOREBOARD:START -->"
END_MARKER = "<!-- SCOREBOARD:END -->"

# training experiment -> (label, {test experiment: label}), in display order. Each
# training experiment is a group of metric columns; each cell stacks the values of
# its tests, in this order (top to bottom)
TRAINING_GROUPS = {
    "ESD_pseudo_reality": (
        "ESD",
        {
            "Perfect_cross_validation": "Perfect cross-validation",
            "Perfect_extrapolation": "Perfect extrapolation",
        },
    ),
    "Emulator_hist_future": (
        "Emulator",
        {
            "Perfect_cross_validation": "Perfect cross-validation",
            "Perfect_interpolation": "Perfect interpolation",
        },
    ),
}

# (training experiment, test experiment) -> label, in display order
SCOREBOARD_EXPERIMENTS = {
    (train_exp, test_exp): f"{train_label}, {test_label}"
    for train_exp, (train_label, tests) in TRAINING_GROUPS.items()
    for test_exp, test_label in tests.items()
}

# variable -> {metric key in metrics_summary.json: (label, higher_is_better)}
METRICS = {
    "tasmax": {
        "rmse": ("RMSE", False),
        "bias_mean": ("Clim. Mean", False),
        "bias_max1day": ("TXx", False),
        "ralsd": ("RALSD", False),
        "pss": ("PSS", True),
        "bias_annstd": ("IAV", False),
    },
    "pr": {
        "rmse": ("RMSE", False),
        "bias_mean": ("Clim. Mean", False),
        "bias_sdii": ("SDII", False),
        "bias_max1day": ("Rx1day", False),
        "ralsd": ("RALSD", False),
        "lhd": ("LHD", False),
    },
}

# `stochastic_output` in data/<MODEL>/metadata.yaml -> model type; the scoreboard
# shows one group of rows per type, in this order (models without metadata last)
MODEL_TYPES = {
    False: "Deterministic",
    True: "Generative",
}
UNKNOWN_TYPE = "Type not registered"

VARIABLE_LABELS = {
    "tasmax": "Daily maximum temperature",
    "pr": "Daily precipitation",
}

LEGEND = """\
Metrics are computed per domain by `ml-eval benchmark` and aggregated across
domains (quadratic mean for RMSE and LHD, arithmetic mean otherwise). Biases are
spatial means of the absolute bias, in the units of the variable. ↓ lower is
better, ↑ higher is better. Each cell shows the two tests of a training
experiment, in the order given in the column header; the best value of each test
is in bold, and – marks results not available. Models using orography as a predictor are in italics.
"""


def parse_args() -> argparse.Namespace:
    """
    Parse the command-line arguments.

    Returns
    -------
    argparse.Namespace
        Arguments, with the attribute `print`.
    """
    parser = argparse.ArgumentParser(
        description="Build the scoreboard tables of README.md."
    )
    parser.add_argument(
        "--print",
        action="store_true",
        help="print the tables to stdout instead of updating README.md",
    )
    return parser.parse_args()


def collect(data_dir: Path = DATA_DIR) -> dict[str, dict[tuple[str, str], dict]]:
    """
    Read the metric summaries of all models.

    Parameters
    ----------
    data_dir : Path
        Directory holding one sub-directory per model.

    Returns
    -------
    dict[str, dict[tuple[str, str], dict]]
        {model: {(training experiment, test experiment): summary}}, models sorted
        alphabetically by name (case-insensitive).
    """
    results: dict[str, dict[tuple[str, str], dict]] = {}
    for file in data_dir.glob(f"*/evaluation/*/*/{SUMMARY_FILE}"):
        test_exp = file.parent.name
        train_exp = file.parent.parent.name
        model = file.parents[3].name
        with open(file) as f:
            results.setdefault(model, {})[(train_exp, test_exp)] = json.load(f)
    return dict(sorted(results.items(), key=lambda item: item[0].lower()))


def model_type(model: str, data_dir: Path = DATA_DIR) -> str:
    """
    Type of a model (a value of `MODEL_TYPES`), from its metadata.

    Parameters
    ----------
    model : str
        Model directory name under `data_dir`.
    data_dir : Path
        Directory holding one sub-directory per model.

    Returns
    -------
    str
        Value of `MODEL_TYPES` for its `stochastic_output`, or `UNKNOWN_TYPE` if the
        model has no metadata file or the field is missing/null.
    """
    file = data_dir / model / METADATA_FILE
    if not file.exists():
        return UNKNOWN_TYPE
    metadata = yaml.safe_load(file.read_text()) or {}
    return MODEL_TYPES.get(metadata.get("stochastic_output"), UNKNOWN_TYPE)


def _format(value: float | None) -> str:
    """Format a metric value with 3 significant digits; None -> en dash."""
    if value is None:
        return "–"
    if abs(value) >= 1000:
        return f"{value:.0f}"
    return f"{value:.3g}"


def _domains(summary: dict, var: str) -> set[str]:
    """Domains covered by the aggregates of one variable in a summary."""
    metrics = summary.get("variables", {}).get(var, {})
    return {domain for metric in metrics.values() for domain in metric["domains"]}


def build_table(
    results: dict[str, dict[tuple[str, str], dict]],
    var: str,
    all_domains: list[str],
    types: dict[str, str],
) -> str:
    """
    Build the HTML table of one variable.

    Rows are grouped by model type (deterministic, generative, then models without
    metadata), each group under a header row; the best values are marked over all
    models. Models using orography (`-orog` suffix) are in italics. Missing
    experiments, metrics or null aggregates are shown as an en dash; they
    are never filled. Models whose aggregates do not cover all the benchmark
    domains in some experiment are marked with a dagger and listed, with the
    experiment and the domains used, in a footnote.

    Parameters
    ----------
    results : dict
        Output of `collect`.
    var : str
        Variable, a key of `METRICS`.
    all_domains : list[str]
        All benchmark domains, from `benchmark/datasets.yaml`.
    types : dict[str, str]
        Type of each model in `results` (see `model_type`).

    Returns
    -------
    str
        HTML table followed by its footnotes (if any).
    """
    metrics = METRICS[var]

    # values[model][(experiment, metric)] = aggregate or None
    values: dict[str, dict[tuple, float | None]] = {}
    partial: dict[str, list[str]] = {}  # model -> footnote entries
    for model, summaries in results.items():
        row = {}
        for exp in SCOREBOARD_EXPERIMENTS:
            summary = summaries.get(exp)
            var_metrics = (summary or {}).get("variables", {}).get(var, {})
            for metric in metrics:
                row[(exp, metric)] = var_metrics.get(metric, {}).get("aggregate")
            if summary is not None:
                domains = _domains(summary, var)
                if domains and set(all_domains) - domains:
                    exp_label = SCOREBOARD_EXPERIMENTS[exp]
                    used = ", ".join(d for d in all_domains if d in domains)
                    partial.setdefault(model, []).append(f"{exp_label}: {used}")
        if any(v is not None for v in row.values()):
            values[model] = row

    # models per type, in display order (alphabetical within a type)
    groups: dict[str, list[str]] = {}
    for group in [*MODEL_TYPES.values(), UNKNOWN_TYPE]:
        members = [model for model in values if types[model] == group]
        if members:
            groups[group] = members

    # best value per test and metric, over all models
    best = {}
    for exp in SCOREBOARD_EXPERIMENTS:
        for metric, (_, higher_is_better) in metrics.items():
            column = [row[(exp, metric)] for row in values.values()]
            column = [v for v in column if v is not None]
            if column:
                best[(exp, metric)] = max(column) if higher_is_better else min(column)

    lines = ["<table>", "  <thead>", "    <tr>", '      <th rowspan="2">Model</th>']
    for train_label, tests in TRAINING_GROUPS.values():
        order = " / ".join(tests.values())
        lines.append(
            f'      <th colspan="{len(metrics)}">{train_label}<br>'
            f"<sub>{order}</sub></th>"
        )
    lines += ["    </tr>", "    <tr>"]
    for _ in TRAINING_GROUPS:
        for label, higher_is_better in metrics.values():
            arrow = "↑" if higher_is_better else "↓"
            lines.append(f"      <th>{label} {arrow}</th>")
    lines += ["    </tr>", "  </thead>", "  <tbody>"]
    n_columns = 1 + len(TRAINING_GROUPS) * len(metrics)
    for group, members in groups.items():
        lines.append(f'    <tr><th colspan="{n_columns}" align="left">{group}</th></tr>')
        for model in members:
            row = values[model]
            name = f"<i>{model}</i>" if model.endswith(OROG_SUFFIX) else model
            if model in partial:
                name += "<sup>†</sup>"
            lines += ["    <tr>", f"      <td>{name}</td>"]
            for train_exp, (_, tests) in TRAINING_GROUPS.items():
                for metric in metrics:
                    cell = []
                    for test_exp in tests:
                        key = ((train_exp, test_exp), metric)
                        text = _format(row[key])
                        if row[key] is not None and row[key] == best.get(key):
                            text = f"<b>{text}</b>"
                        cell.append(text)
                    lines.append(f'      <td align="right">{"<br>".join(cell)}</td>')
            lines.append("    </tr>")
    lines += ["  </tbody>", "</table>"]

    if partial:
        lines.append("")
        notes = "; ".join(
            f"{model}, {entry}"
            for model, entries in partial.items()
            for entry in entries
        )
        lines.append(f"† Aggregated over a subset of domains only ({notes}).")
    return "\n".join(lines)


def render(results: dict[str, dict[tuple[str, str], dict]]) -> str:
    """
    Render the full scoreboard block (legend and one table per variable).

    Parameters
    ----------
    results : dict
        Output of `collect`.

    Returns
    -------
    str
        Markdown/HTML text to place between the scoreboard markers.
    """
    with open(BENCHMARK_DIR / "datasets.yaml") as f:
        all_domains = list(yaml.safe_load(f))

    types = {model: model_type(model) for model in results}
    parts = [LEGEND]
    for var in METRICS:
        parts.append(f"### {VARIABLE_LABELS[var]}\n")
        # blank lines around the HTML so GitHub renders the Markdown that follows
        parts.append(build_table(results, var, all_domains, types) + "\n")
    return "\n".join(parts)


def update_readme(
    readme: Path,
    block: str,
    start_marker: str = START_MARKER,
    end_marker: str = END_MARKER,
) -> bool:
    """
    Replace the text between two markers of a README file.

    Parameters
    ----------
    readme : Path
        README file containing `start_marker` and `end_marker`.
    block : str
        New content between the markers.
    start_marker, end_marker : str
        Markers delimiting the block; by default, those of the scoreboard.

    Returns
    -------
    bool
        True if the file changed.

    Raises
    ------
    ValueError
        If the markers are missing or in the wrong order.
    """
    text = readme.read_text()
    start = text.find(start_marker)
    end = text.find(end_marker)
    if start < 0 or end < start:
        raise ValueError(f"Markers {start_marker} / {end_marker} not found in {readme}")
    new_text = (
        text[: start + len(start_marker)] + "\n\n" + block.strip() + "\n\n" + text[end:]
    )
    if new_text == text:
        return False
    readme.write_text(new_text)
    return True


def main() -> None:
    """Collect the metric summaries and print or write the scoreboard."""
    args = parse_args()
    block = render(collect())
    if args.print:
        print(block)
    elif update_readme(README_FILE, block):
        print(f"[scoreboard] INFO | Scoreboard updated: {README_FILE}")
    else:
        print(f"[scoreboard] INFO | Scoreboard already up to date: {README_FILE}")


if __name__ == "__main__":
    main()
