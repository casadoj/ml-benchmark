#!/bin/bash
# ============================================================================
# Precipitation skill scorecard: one models x quantities heatmap for "pr".
# METRICS below picks the columns (see METRIC_LABELS in the package for the
# full menu); the metrics whose value is a precipitation amount are converted
# from the stored kg m-2 s-1 to mm/day for display.
#
# The plotting logic lives in the ml-evaluation package (ml_evaluation.viz), so
# this script only resolves the metric directories and calls the entry point.
# viz searches nothing: every source is passed as an explicit label -> path,
# where <path> is one run's <SEASON> dir and viz appends <var> itself.
#
# Reads   data/<SIM>/evaluation/<DOMAIN>/<RCM>_<TRAIN_GCM>_<DATASET>_<PERIOD>/<SEASON>/pr/
# Writes  the PNG(s) next to this script.
#
# Run:   bash   figures/scorecard_pr_skill/plot.sh      (from anywhere)
#        sbatch figures/scorecard_pr_skill/plot.sh
# ============================================================================
#SBATCH --job-name=sc_pr_skill
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
HERE="$PROJECT/figures/scorecard_pr_skill"       # figures are written here, next to this script
cd "$HERE" || exit 1

# ---------------------------- PARAMETERS ------------------------------------
# Python helpers shared by the figure scripts live in figures/utils.py
export PYTHONPATH="$PROJECT/figures${PYTHONPATH:+:$PYTHONPATH}"
export DATA_DIR="$PROJECT/data"
export DOMAINS="ALPS NZ SA"
export TRAIN_EXPERIMENTS="ESD_pseudo_reality Emulator_hist_future"
export SEASON="annual"
export VARS="pr"
export OUT="$HERE"
# Columns, in order. The 10 fast-track metrics; append the slow-track ones
#   wd wdh fcss lhd bias_annstd bias_p90
# once data/*/evaluation.sh has run its `ml-eval slow` block.
export METRICS="rmse bias_mean bias_sdii bias_rx1day ralsd lhd" # bias_p01 bias_p99 bias_r01 bias_p98wet bias_acorr"


# ---------------------------- RUN ------------------------------------------
python <<'PY'
import os
from pathlib import Path
import yaml

from ml_evaluation.viz.plot_var_skill_scorecard import (
    read_var_skill_metrics,
    render_var_skill_scorecard,
)
from utils import (
    aggregate_domains,
    apply_model_override,
    keep,
    missing_metrics,
    run_dir,
    save_var_skill_scorecard,
)

DATA_DIR = Path(os.environ["DATA_DIR"])
DOMAINS = os.environ["DOMAINS"].split()
TRAIN_EXPERIMENTS = os.environ["TRAIN_EXPERIMENTS"].split()
SEASON = os.environ["SEASON"]
OUT = Path(os.environ["OUT"])
VARS = os.environ["VARS"].split()
METRICS = os.environ["METRICS"].split()
# label -> (simulation dir, checkpoint tag). The tag is the prediction-file
# prefix, which is not always the dir name.
MODELS = [
    # ("ANN", "ANN", "ANN"),
    # ("ANN-orog", "ANN-orog", "ANN-orog"),
    # ("CorrDiff-TW1", "CorrDiff-TW1", "CorrDiff-TW1"),
    # ("CorrDiff-TW1_NTNU-CWA", "CorrDiff-TW1_NTNU-CWA", "CorrDiff-TW1_NTNU-CWA"),
    # ("CorrDiff-TW1_NTNU-CWA-orog", "CorrDiff-TW1_NTNU-CWA-orog", "CorrDiff-TW1_NTNU-CWA-orog"),
    # ("DeepESD_IDL", "DeepESD_IDL", "DeepESD_IDL"),
    ("DeepESD-IFCAv1", "DeepESD-IFCAv1", "DeepESD-IFCAv1"),
    ("DeepESD-IFCAv1-orog", "DeepESD-IFCAv1-orog", "DeepESD-IFCAv1-orog"),
    # ("DeepESDcrps_IFCAv2-orog", "DeepESDcrps_IFCAv2-orog", "DeepESDcrps_IFCAv2-orog"),
    ("DetUNet", "DetUNet", "DetUNet"),
    ("DetUNet-orog", "DetUNet-orog", "DetUNet-orog"),
    ("DetUNet-v2", "DetUNet-v2", "DetUNet-v2"),
    ("DetUNet-v2-orog", "DetUNet-v2-orog", "DetUNet-v2-orog"),
]

with (OUT.parent / "experiments.yaml").open() as file:
    experiment_mapping = yaml.safe_load(file)

with (OUT.parent / "datasets.yaml").open() as file:
    dataset_mapping = yaml.safe_load(file)


MODELS = apply_model_override(MODELS)


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

        for var in VARS:
            available_paths = keep(paths, DOMAINS, var)
            per_model = {}
            for model, domain_dict in available_paths.items():
                # load results for each domain
                results = {}
                for domain, base_path in domain_dict.items():
                    path = base_path / var
                    results[domain] = read_var_skill_metrics(path, var, METRICS)

                missing = missing_metrics(results, METRICS)
                if missing:
                    details = "; ".join(
                        f"{domain}: {', '.join(metrics)}"
                        for domain, metrics in missing.items()
                    )
                    print(
                        f"[plot] SKIP {model}: values missing for "
                        f"{details}"
                    )
                    continue

                # aggregate metrics across domains
                aggregated = aggregate_domains(results)
                if aggregated:
                    per_model[model] = aggregated

            if not per_model:
                print(f"[plot] {var}: no metrics found — skipping.")
                continue

            # plot scorecard
            filestem = f'var_skill_scorecard_{var}_{SEASON}_{train_exp_name}_{case}_{period}'
            print(render_var_skill_scorecard(
                per_model,
                var,
                out_dir=OUT,
                filename=f'{filestem}.png',
                models=list(per_model),
                metrics=METRICS,
                season=SEASON,
                title=f'Precipitation: {train_exp_name.title()} — {case.title()} — {period}',
            ))

            # save aggregated metrics
            save_var_skill_scorecard(per_model, filename=f'{filestem}.csv')

PY
