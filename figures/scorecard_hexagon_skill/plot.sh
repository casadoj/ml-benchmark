#!/bin/bash
# ============================================================================
# Skill scorecard: models x variables, each cell a six-wedge hexagon coloured
# by % improvement over the reference model on the six fast-track metrics.
#
# The plotting logic lives in the ml-evaluation package (ml_evaluation.viz), so
# this script only resolves the metric directories and calls the entry point.
# viz searches nothing: every source is passed as an explicit label -> path,
# where <path> is one run's <SEASON> dir and viz appends <var> itself.
#
# Reads   data/<SIM>/evaluation/<DOMAIN>/<EXPERIMENT>/<RCM>_<TRAIN_GCM>_<DATASET>_<PERIOD>/<SEASON>/<VAR>/
# Writes  the PNG(s) next to this script.
#
# Run:   bash   figures/scorecard_hexagon_skill/plot.sh      (from anywhere)
#        sbatch figures/scorecard_hexagon_skill/plot.sh
# ============================================================================
#SBATCH --job-name=sc_hex_skill
#SBATCH --output=./logs/plot-%x-%j.out
#SBATCH --error=./logs/plot-%x-%j.err
#SBATCH --partition=sci
#SBATCH --time=01:00:00
#SBATCH --mem=0

# --- Environment (must contain the ml-evaluation package) -------------------
# Skipped when plot_master.sh already provides the environment, so these
# machine-specific paths are only used for a standalone run.
if [ -z "$PLOT_ENV_READY" ]; then
    source /home/casadoj/miniconda3/etc/profile.d/conda.sh
    conda activate /home/casadoj/miniconda3/envs/rcm-emulation
fi

# ---------------------------- DIRECTORIES -----------------------------------
PROJECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HERE="$PROJECT/figures/scorecard_hexagon_skill"       # figures are written here, next to this script
cd "$HERE"

# ---------------------------- PARAMETERS ------------------------------------
export DATA_DIR="$PROJECT/data"
export DOMAINS="ALPS NZ SA"
export TRAIN_EXPERIMENTS="ESD_pseudo_reality Emulator_hist_future"
export SEASON="annual"
export VARS="tasmax pr"
export OUT="$HERE"
export REFERENCE="DeepESD-IFCAv1"   # baseline row for the % improvement


# ---------------------------- RUN ------------------------------------------
python <<'PY'
import os
import sys
from pathlib import Path
import yaml

from ml_evaluation.viz.plot_hexagon import plot_multivar_skill_scorecard

sys.path.insert(0, str(Path.cwd().parent))
from utils import (
    # aggregate_domains,
    apply_model_override,
    keep,
    # missing_metrics,
    run_dir,
)

DATA_DIR = Path(os.environ["DATA_DIR"])
DOMAINS = os.environ["DOMAINS"].split()
TRAIN_EXPERIMENTS = os.environ["TRAIN_EXPERIMENTS"].split()
SEASON = os.environ["SEASON"]
OUT = Path(os.environ["OUT"])
VARS = os.environ["VARS"].split()
REFERENCE = os.environ["REFERENCE"]

# label -> (simulation dir, checkpoint tag). The tag is the prediction-file
# prefix, which is not always the dir name (RESDIFF_V3 -> RESDIFF, ...).
MODELS = [
    ("ANN", "ANN", "ANN"),
    ("ANN-orog", "ANN-orog", "ANN-orog"),
    # ("CorrDiff-TW1", "CorrDiff-TW1", "CorrDiff-TW1"),
    # ("CorrDiff-TW1_NTNU-CWA", "CorrDiff-TW1_NTNU-CWA", "CorrDiff-TW1_NTNU-CWA"),
    # ("CorrDiff-TW1_NTNU-CWA-orog", "CorrDiff-TW1_NTNU-CWA-orog", "CorrDiff-TW1_NTNU-CWA-orog"),
    ("DeepESD_IDL", "DeepESD_IDL", "DeepESD_IDL"),
    ("DeepESD-IFCAv1", "DeepESD-IFCAv1", "DeepESD-IFCAv1"),
    ("DeepESD-IFCAv1-orog", "DeepESD-IFCAv1-orog", "DeepESD-IFCAv1-orog"),
    ("DeepESDcrps_IFCAv2", "DeepESDcrps_IFCAv2", "DeepESDcrps_IFCAv2"),
    # ("DeepESDcrps_IFCAv2-orog", "DeepESDcrps_IFCAv2-orog", "DeepESDcrps_IFCAv2-orog"),
    ("DetUNet", "DetUNet", "DetUNet"),
    ("DetUNet-orog", "DetUNet-orog", "DetUNet-orog"),
    ("DetUNet-v2", "DetUNet-v2", "DetUNet-v2"),
    ("DetUNet-v2-orog", "DetUNet-v2-orog", "DetUNet-v2-orog"),
]
MODELS = apply_model_override(MODELS)

with (OUT.parent / "experiments.yaml").open() as file:
    experiment_mapping = yaml.safe_load(file)

with (OUT.parent / "datasets.yaml").open() as file:
    dataset_mapping = yaml.safe_load(file)


for train_exp in TRAIN_EXPERIMENTS:

    train_exp_name = train_exp.split('_')[0].lower()

    for test_exp, attrs in experiment_mapping[train_exp].items():

        period, case = attrs['period'], attrs['case']

        print(f"\n[plot] train={train_exp_name} | framework={case} | period={period}")

        # Define run directories for each model and domain
        paths = {}
        for model, sim, _ in MODELS:
            run_dirs = {}
            for domain in DOMAINS:
                mapping = dataset_mapping[domain]
                rcm = mapping["rcm"]
                train_gcm = mapping["train_gcm"]
                test_gcm = mapping["test_gcm"]
                dataset = train_gcm if case == "perfect" else test_gcm
                run_dirs[domain] = run_dir(
                    DATA_DIR, sim, domain, train_exp, rcm, train_gcm,
                    dataset, period, SEASON,
                )
            paths[model] = run_dirs

        available_paths = keep(paths, DOMAINS, VARS)

        if REFERENCE not in available_paths:
            raise SystemExit(f"[plot] reference {REFERENCE!r} has no metrics — nothing to plot.")

        for domain in DOMAINS:
            # extract paths for a domain
            paths_domain = {model: dct[domain] for model, dct in available_paths.items()}
            # plot domain-specific scorecard
            filestem = f'scorecard_skill_{SEASON}_{train_exp_name}_{case}_{period}_{domain}'
            print(plot_multivar_skill_scorecard(
                paths_domain, OUT, VARS, 
                reference=REFERENCE, 
                season=SEASON,
                title=f"Scorecard — {domain} — {SEASON}",
                filename=f'{filestem}.png'
            ))

PY
