#!/bin/bash
# ============================================================================
# Precipitation skill scorecard: one models x quantities heatmap for pr.
# METRICS below picks the columns (see METRIC_LABELS in the package for the
# full menu); the metrics whose value is a precipitation amount are converted
# from the stored kg m-2 s-1 to mm/day for display.
#
# The plotting logic lives in the ml-evaluation package (ml_evaluation.viz), so
# this script only resolves the metric directories and calls the entry point.
# viz searches nothing: every source is passed as an explicit label -> path,
# where <path> is one run's <SEASON> dir and viz appends <var> itself.
#
# Reads   data/<SIM>/evaluation/<CKPT>/<CKPT>_<RCM>_<TRAIN_GCM>_<DATASET>_<PERIOD>/<SEASON>/<VAR>/
# Writes  the PNG(s) next to this script.
#
# Run:   bash   figures/scorecard_pr_skill/plot.sh      (from anywhere)
#        sbatch figures/scorecard_pr_skill/plot.sh
# ============================================================================
#SBATCH --job-name=sc_pr_skill
#SBATCH --output=./logs/plot.out
#SBATCH --error=./logs/plot.err
#SBATCH --partition=wncompute_meteo
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
cd "$HERE"
mkdir -p logs

# ---------------------------- PARAMETERS ------------------------------------
export DATA_DIR="$PROJECT/data"
export DOMAIN="ALPS"
export RCM="CNRM-ALADIN63"          # downscaling target RCM
export TRAIN_GCM="CNRM-CM5"         # GCM the emulators were trained on
export TEST_GCM="MPI-ESM-LR"        # GCM driving the case being plotted
export CASE="perfect"               # perfect = upscaled-RCM input, imperfect = raw GCM
export HORIZON="mid_century"
export PERIOD="2041-2060"
export SEASON="annual"
export VARS="pr"
export OUT="$HERE"
# Columns, in order. The 10 fast-track metrics; append the slow-track ones
#   wd wdh fcss lhd bias_annstd bias_p90
# once data/*/evaluation.sh has run its `ml-eval slow` block.
# export METRICS="rmse bias_mean bias_p01 bias_p99 bias_rx1day bias_r01 bias_sdii bias_p98wet ralsd bias_acorr"
export METRICS="rmse bias_mean bias_sdii bias_rx1day ralsd lhd" # bias_p01 bias_p99 bias_r01 bias_p98wet bias_acorr"
# Predictions and the RCM truth are stored in kg m-2 s-1 here, so the pr amount
# columns are converted to mm/day for display.
export PR_SCALE="86400.0"


# ---------------------------- RUN ------------------------------------------
python <<'PY'
import os

DATA_DIR = os.environ["DATA_DIR"]
DOMAIN = os.environ["DOMAIN"]
# TODO: iterate over domains and compute the mean
# TODO: function that defines RCM, train GCM and test GCM for each domain
RCM, TRAIN_GCM, TEST_GCM = os.environ["RCM"], os.environ["TRAIN_GCM"], os.environ["TEST_GCM"]
HORIZON, PERIOD, SEASON = os.environ["HORIZON"], os.environ["PERIOD"], os.environ["SEASON"]
OUT = os.environ["OUT"]
VARS = os.environ["VARS"].split()

# The input dataset is the 4th field of every prediction/run name.
# DATASET = f"UPS-{RCM}-{TEST_GCM}" if os.environ["CASE"] == "perfect" else TEST_GCM
DATASET = TRAIN_GCM if os.environ["CASE"] == "perfect" else TEST_GCM

def run_dir(sim, domain):
    """One run's season dir: viz appends <var> to it."""
    stem = f"{RCM}_{TRAIN_GCM}_{DATASET}_{PERIOD}"
    return os.path.join(DATA_DIR, sim, "evaluation", f"{domain}_Domain", stem, SEASON)


def rcm_dir(domain):
    """The RCM truth: no model and no input dataset in its run name."""
    stem = f"{RCM}_{TEST_GCM}_{PERIOD}"
    return os.path.join(DATA_DIR, "target", f"{domain}_domain", PERIOD, "target", "evaluation", "rcm", stem, SEASON)


def keep(paths):
    """Drop sources with no metrics on disk, saying which."""
    out = {}
    for label, path in paths.items():
        if os.path.isdir(path):
            out[label] = path
        else:
            print(f"[plot] skip {label}: {path} not found")
    return out

# label -> (simulation dir, checkpoint tag). The tag is the prediction-file
# prefix, which is not always the dir name (RESDIFF_V3 -> RESDIFF, ...).
MODELS = [
    # ("UNET-SINGLE",        "UNET-SINGLE",        "UNET-SINGLE"),
    # ("UNET-MULTI",         "UNET-MULTI",         "UNET-MULTI"),
    # ("UNET-MULTI-v2-100",  "UNET-MULTI-v2",      "UNET-MULTI-v2100"),
    # ("UNET-MULTI-v2-200",  "UNET-MULTI-v2",      "UNET-MULTI-v2200"),
    # ("UNET-MULTI-v2-300",  "UNET-MULTI-v2",      "UNET-MULTI-v2300"),
    # ("UNET-MULTI-v2-400",  "UNET-MULTI-v2",      "UNET-MULTI-v2400"),
    # ("UNET-MULTI-v2-500",  "UNET-MULTI-v2",      "UNET-MULTI-v2500"),
    # ("UNET-MULTI-v2-600",  "UNET-MULTI-v2",      "UNET-MULTI-v2600"),
    # ("UNET-MULTI-v2-700",  "UNET-MULTI-v2",      "UNET-MULTI-v2700"),
    # ("UNET-MULTI-v3",      "UNET-MULTI-v3",      "UNET-MULTI-v3"),
    # ("RESDIFF_V3",         "RESDIFF_V3",         "RESDIFF"),
    # ("UIBCORRDIFF",        "UIBCORRDIFF",        "UiBCorrDiff"),
    # ("DOWNVIT",            "DOWNVIT",            "DOWNVIT"),
    # ("FLOWMATCHING",       "FLOWMATCHING",       "FlowMatchingLocalTargets"),
    # ("FLOWMATCHINGPRECIP", "FLOWMATCHINGPRECIP", "FlowMatchingLocalPrecip"),
    ("DeepESD-IFCAv1",      "DeepESD-IFCAv1",       "DeepESD-IFCAv1")
]

# ./figures/plot_master.sh can impose ONE roster on every figure of a sweep by
# exporting PLOT_MODELS: whitespace-separated entries, each either a LABEL
# already listed above (its simulation dir and checkpoint tag are reused) or an
# explicit "LABEL,SIMDIR,CKPT" for a model this figure does not know yet. It
# REPLACES the list above, in the order given. Unset -> the list above stands,
# so running this script alone behaves exactly as before.
_override = os.environ.get("PLOT_MODELS", "").split()
if _override:
    _known = {m[0]: m for m in MODELS}
    MODELS = []
    for _entry in _override:
        _parts = _entry.split(",")
        if len(_parts) == 3:
            MODELS.append(tuple(_parts))
        elif len(_parts) != 1:
            raise SystemExit(
                f"[plot] PLOT_MODELS: {_entry!r} is neither a label nor "
                '"LABEL,SIMDIR,CKPT".'
            )
        elif _entry in _known:
            MODELS.append(_known[_entry])
        else:
            print(f"[plot] PLOT_MODELS: {_entry} is not one of this figure's "
                  f"models -- assuming sim dir and checkpoint tag {_entry!r}")
            MODELS.append((_entry, _entry, _entry))
    print(f"[plot] PLOT_MODELS: {' '.join(m[0] for m in MODELS)}")
paths = {label: run_dir(sim, DOMAIN) for label, sim, ckpt in MODELS}

from ml_evaluation.viz.plot_var_skill_scorecard import (
    read_var_skill_metrics,
    render_var_skill_scorecard,
)

paths = keep(paths)
METRICS = os.environ["METRICS"].split()

# ml-eval stores precip in the units of the files it read, which differ per
# project, so PR_SCALE above carries the factor to mm/day. Only the amount
# columns are scaled; the frequency (r01) and the dimensionless scores (ralsd,
# acorr, fcss, lhd) are not. The CV printed under each value is a ratio and is
# unaffected either way.
PR_TO_MM_DAY = float(os.environ["PR_SCALE"])
AMOUNT_METRICS = {
    "rmse", "bias_mean", "bias_p01", "bias_p99", "bias_rx1day",
    "bias_sdii", "bias_p98wet", "wd", "wdh", "bias_annstd", "bias_p90",
}

for var in VARS:
    scale = PR_TO_MM_DAY if var == "pr" else 1.0
    per_model = {}
    for label, base in paths.items():
        d = os.path.join(base, var)
        if not os.path.isdir(d):
            continue
        m = read_var_skill_metrics(d, var, METRICS)
        per_model[label] = {
            k: ((v * scale if k in AMOUNT_METRICS else v), cv)
            for k, (v, cv) in m.items()
        }
    if not per_model:
        print(f"[plot] {var}: no metrics found — skipping.")
        continue
    print(render_var_skill_scorecard(
        per_model, var, OUT, models=list(per_model), metrics=METRICS,
        season=SEASON,
    ))

PY
