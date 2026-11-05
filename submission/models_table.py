#!/usr/bin/env python
"""
Build the table of contributing models in README.md from the models' metadata.

Reads `data/<MODEL>/metadata.yaml` (see `submission/metadata_template.yaml`) for
every model and writes an HTML table (Model | Description | Reference |
Implementation) between the markers `<!-- MODELS:START -->` and
`<!-- MODELS:END -->` in README.md.

A model and its orography variant (`<MODEL>-orog`) share one row, named after the
model without the suffix and filled from the metadata of the version without
orography when both exist. Models are grouped by type, from `stochastic_output`
(deterministic, generative, then models whose type is not registered), each group
under a full-width header row as in the scoreboard, and sorted alphabetically
(case-insensitive) within each group.

Usage
-----
    python submission/models_table.py            # update README.md in place
    python submission/models_table.py --print    # print the table to stdout instead
"""
from __future__ import annotations

import argparse
import html
import sys
from pathlib import Path
from urllib.parse import urlparse

import yaml

ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
README_FILE = ROOT_DIR / "README.md"
METADATA_FILE = "metadata.yaml"
START_MARKER = "<!-- MODELS:START -->"
END_MARKER = "<!-- MODELS:END -->"
OROG_SUFFIX = "-orog"

# table columns, in display order
COLUMNS = ("Model", "Description", "Reference", "Implementation")

# text shown for a missing reference or implementation
MISSING = "In preparation"

# host of the implementation URL -> link text; any other host shows "Link"
HOST_LABELS = {
    "github.com": "GitHub",
    "gitlab.com": "GitLab",
    "zenodo.org": "Zenodo",
}

# metadata fields that must be present (they may be null)
REQUIRED_FIELDS = (
    "emulator_id",
    "short_description",
    "reference_label",
    "reference_url",
    "reproducibility_url",
    "stochastic_output",
)

# sys.path is extended so the README helper shared with the scoreboard can be reused
sys.path.insert(0, str(ROOT_DIR / "evaluation"))
from scoreboard import MODEL_TYPES, UNKNOWN_TYPE, update_readme  # noqa: E402


def parse_args() -> argparse.Namespace:
    """
    Parse the command-line arguments.

    Returns
    -------
    argparse.Namespace
        Arguments, with the attribute `print`.
    """
    parser = argparse.ArgumentParser(
        description="Build the table of contributing models of README.md."
    )
    parser.add_argument(
        "--print",
        action="store_true",
        help="print the table to stdout instead of updating README.md",
    )
    return parser.parse_args()


def collect(data_dir: Path = DATA_DIR) -> list[dict]:
    """
    Read the metadata of every model.

    Parameters
    ----------
    data_dir : Path
        Directory with one subdirectory per model.

    Returns
    -------
    list of dict
        Metadata of each model, with the key `model` set to its directory name.

    Raises
    ------
    ValueError
        If a metadata file lacks a required field.
    """
    models = []
    for path in sorted(data_dir.glob(f"*/{METADATA_FILE}")):
        metadata = yaml.safe_load(path.read_text()) or {}
        missing = [field for field in REQUIRED_FIELDS if field not in metadata]
        if missing:
            raise ValueError(f"{path} lacks the field(s): {', '.join(missing)}")
        metadata["model"] = path.parent.name
        models.append(metadata)
    return models


def merge_orography(models: list[dict]) -> list[dict]:
    """
    Keep one entry per model, merging each `<MODEL>-orog` with `<MODEL>`.

    The entry of the version without orography is kept when both exist.

    Parameters
    ----------
    models : list of dict
        Metadata as returned by `collect`.

    Returns
    -------
    list of dict
        Metadata with the key `name` (model name without the orography suffix).
    """
    merged: dict[str, dict] = {}
    for metadata in models:
        name = metadata["model"].removesuffix(OROG_SUFFIX)
        is_orog = metadata["model"] != name
        # the version without orography fills the row when both exist
        if name not in merged or not is_orog:
            merged[name] = {**metadata, "name": name}
    return list(merged.values())


def _text(value: str) -> str:
    """Make a text safe for an HTML table cell (whitespace collapsed)."""
    return html.escape(" ".join(str(value).split()), quote=False)


def _link(label: str, url: str) -> str:
    """HTML link."""
    return f'<a href="{html.escape(url, quote=True)}">{_text(label)}</a>'


def _reference(
    label: str | list[str] | None, url: str | list[str] | None
) -> str:
    """
    Render the reference column.

    `label` and `url` may be lists (several references), paired by position and
    separated by "; " in the table.
    """
    if isinstance(label, list) or isinstance(url, list):
        labels = label if isinstance(label, list) else [label]
        urls = url if isinstance(url, list) else [url]
        if len(labels) != len(urls):
            raise ValueError(
                f"reference_label {labels} and reference_url {urls} differ in length"
            )
        return "; ".join(_reference(lab, u) for lab, u in zip(labels, urls))
    if label is None:
        return _link("Link", url) if url else MISSING
    return _link(label, url) if url else _text(label)


def _implementation(url: str | None) -> str:
    """Render the implementation column, labelling the link by its host."""
    if not url:
        return MISSING
    host = urlparse(url).netloc.lower().removeprefix("www.")
    label = HOST_LABELS.get(host, "GitLab" if host.startswith("gitlab.") else "Link")
    return _link(label, url)


def render(models: list[dict]) -> str:
    """
    Render the HTML table of contributing models.

    Parameters
    ----------
    models : list of dict
        Metadata as returned by `collect`.

    Returns
    -------
    str
        HTML table with one row per model (orography variants merged), grouped by
        model type under full-width header rows. Types without models are omitted.
    """
    rows = sorted(merge_orography(models), key=lambda m: m["name"].lower())
    lines = ["<table>", "  <thead>", "    <tr>"]
    lines += [f"      <th>{column}</th>" for column in COLUMNS]
    lines += ["    </tr>", "  </thead>", "  <tbody>"]
    for group in [*MODEL_TYPES.values(), UNKNOWN_TYPE]:
        members = [
            m for m in rows
            if MODEL_TYPES.get(m["stochastic_output"], UNKNOWN_TYPE) == group
        ]
        if not members:
            continue
        lines.append(
            f'    <tr><th colspan="{len(COLUMNS)}" align="left">{group}</th></tr>'
        )
        for m in members:
            cells = [
                _text(m["name"]),
                _text(m["short_description"] or ""),
                _reference(m["reference_label"], m["reference_url"]),
                _implementation(m["reproducibility_url"]),
            ]
            lines.append("    <tr>")
            lines += [f"      <td>{cell}</td>" for cell in cells]
            lines.append("    </tr>")
    lines += ["  </tbody>", "</table>"]
    return "\n".join(lines)


def main() -> None:
    """Collect the models' metadata and print or write the table."""
    args = parse_args()
    block = render(collect())
    if args.print:
        print(block)
    elif update_readme(README_FILE, block, START_MARKER, END_MARKER):
        print(f"[models_table] INFO | Models table updated: {README_FILE}")
    else:
        print(f"[models_table] INFO | Models table already up to date: {README_FILE}")


if __name__ == "__main__":
    main()
