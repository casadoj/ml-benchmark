#!/bin/bash
# ============================================================================
# Redraw EVERY figure of this project: run the plot.sh of each figures/<figure>/
# directory, in turn, and report what was drawn and what failed.
#
# Each figure directory owns its own plot.sh -- that is where the parameters of
# that figure live (models, period, season, variables), and this driver leaves
# them alone. It only discovers the scripts, runs them, and collects the
# outcome, so a new figure directory joins the sweep by existing, with no edit
# here.
#
# THE ONE EXCEPTION IS THE MODEL ROSTER. Filling the MODELS array below forces
# the same models, in the same order, on every figure of the sweep, overriding
# each plot.sh's own list -- so the whole document can be redrawn with a model
# added, dropped or reordered from this one place. Left empty (the default),
# every figure keeps its own list and nothing changes.
#
# The figure scripts read the metric stores under data/<SIM>/evaluation/;
# they compute nothing themselves. So this is the script to run
# after an evaluation pass has added or refreshed metrics -- a figure whose
# metrics are missing prints its own "skip" and leaves its PNG untouched.
#
# ONE FAILURE DOES NOT STOP THE SWEEP: every script runs, the failures are
# summarised at the end, and the exit status is non-zero if any failed -- so a
# figure that is mid-development does not hide the rest.
#
# Each script's output goes to its own log, and only a failure's tail is echoed
# here, so this job's log stays readable:
#   figures/logs/plot_<figure>.log
#
# Run:   bash   plot_master.sh                 (from anywhere)
#        sbatch plot_master.sh
#        bash   plot_master.sh scorecard_\*    only matching figures
#        SKIP="event domain" bash plot_master.sh    all but these
#        MODELS in the "SELECT MODELS" block below    one roster for all figures
#
# The arguments are shell patterns matched against the DIRECTORY name, so
# 'scorecard_*' redraws every scorecard and 'time_series_skill' just the one.
# Quote them, or the shell expands them against the current directory first.
# ============================================================================
#SBATCH --job-name=plot_all
#SBATCH --output=./figures/logs/plot_master.out
#SBATCH --error=./figures/logs/plot_master.err
#SBATCH --partition=sci
#SBATCH --time=06:00:00
#SBATCH --mem=0

# No `set -e`: a failing figure must not abort the sweep. Each script is run in
# its own bash, so it also cannot leave this shell's state behind.

# --- Environment (must contain the ml-evaluation package) -------------------
# EDIT THESE TWO LINES for your machine. Each plot.sh carries the same pair, so
# that it stays runnable on its own, but under this driver they are skipped:
# PLOT_ENV_READY below tells every child the environment is already there. So
# this is the ONE place to change when running the sweep on another machine,
# rather than all 30 figure scripts.
source /home/casadoj/miniconda3/etc/profile.d/conda.sh
conda activate /home/casadoj/miniconda3/envs/rcm-emulation
export PLOT_ENV_READY=1

# ---------------------------- DIRECTORIES -----------------------------------
# ============================ EDIT ME ======================================
# Absolute path to the CORDEX-ML-Benchmark project root. This is the ONE line to
# change if you work on a copy of the tree somewhere else.
PROJECT="/home/casadoj/Git/ml-benchmark"
# ===========================================================================
HERE="$PROJECT/figures"
cd "$HERE" || { echo "[master] ABORT: $HERE not found" >&2; exit 1; }
mkdir -p logs

# ---------------------------- SELECT MODELS ---------------------------------
# Optional: ONE roster for the whole sweep. Each figure's plot.sh carries its
# own MODELS list and, left empty here, this driver does not touch it. Fill it
# to override every figure at once -- the usual reason is to redraw the whole
# document with a model added, dropped or reordered, without editing a dozen
# scripts and without them drifting apart.
#
# Each entry is either a LABEL a figure already knows (its simulation dir and
# checkpoint tag are reused, so listing labels is enough to select and reorder)
# or an explicit "LABEL,SIMDIR,CKPT" for a model no figure lists yet:
#
#   MODELS=(UNET-SINGLE UNET-MULTI RESDIFF_V3)
#   MODELS=(UNET-SINGLE "UNET-MULTI-v3,UNET-MULTI-v3,UNET-MULTI-v3")
#
# A label a given figure does not know and cannot resolve is assumed to name
# its own simulation dir and checkpoint tag, and is dropped by that figure if
# no metrics are found there -- so one roster can span figures that do not all
# hold the same models.

MODELS=(
    # "ANN,ANN,ANN"
    # "ANN-orog,ANN-orog,ANN-orog"
    # # "CorrDiff-TW1,CorrDiff-TW1,CorrDiff-TW1"
    # # "CorrDiff-TW1_NTNU-CWA,CorrDiff-TW1_NTNU-CWA,CorrDiff-TW1_NTNU-CWA"
    # # "CorrDiff-TW1_NTNU-CWA-orog,CorrDiff-TW1_NTNU-CWA-orog,CorrDiff-TW1_NTNU-CWA-orog"
    # "DeepESD_IDL,DeepESD_IDL,DeepESD_IDL"
    "DeepESD-IFCAv1,DeepESD-IFCAv1,DeepESD-IFCAv1"
    "DeepESD-IFCAv1-orog,DeepESD-IFCAv1-orog,DeepESD-IFCAv1-orog"
    "DetUNet,DetUNet,DetUNet"
    "DetUNet-orog,DetUNet-orog,DetUNet-orog"
    "DetUNet-v2,DetUNet-v2,DetUNet-v2"
    "DetUNet-v2-orog,DetUNet-v2-orog,DetUNet-v2-orog"
    # "DeepESDcrps_IFCAv2-orog,DeepESDcrps_IFCAv2-orog,DeepESDcrps_IFCAv2-orog"
)

export PLOT_MODELS="${MODELS[*]}"

# ---------------------------- SELECT FIGURES --------------------------------
# Every directory holding a plot.sh, in alphabetical order. A directory without
# one is reported rather than passed over in silence: it is usually a figure
# whose script has not been written yet.
FIGURES=()
for dir in */; do
    name="${dir%/}"
    [ "$name" = "logs" ] && continue

    # Explicit selection (patterns given as arguments) wins over the default of
    # "everything"; SKIP then removes names from whatever was selected. Both are
    # applied BEFORE the plot.sh check, so a scriptless directory is only
    # reported when it was actually asked for.
    if [ $# -gt 0 ]; then
        keep=0
        for pat in "$@"; do
            case "$name" in ($pat) keep=1;; esac
        done
        [ "$keep" = 1 ] || continue
    fi
    for s in $SKIP; do
        case "$name" in ($s) continue 2;; esac
    done

    if [ ! -f "$name/plot.sh" ]; then
        echo "[master] no plot.sh in $name/ -- nothing to run there"
        continue
    fi
    FIGURES+=("$name")
done

if [ ${#FIGURES[@]} -eq 0 ]; then
    echo "[master] nothing selected${*:+ by: $*} -- no figure directory matched." >&2
    exit 1
fi

echo "[master] $PROJECT"
echo "[master] ${#FIGURES[@]} figure(s) to draw: ${FIGURES[*]}"
if [ ${#MODELS[@]} -gt 0 ]; then
    echo "[master] models forced on every figure: ${MODELS[*]}"
else
    echo "[master] models: each figure's own MODELS list"
fi
echo

# ---------------------------------- RUN -------------------------------------
OK=(); FAILED=()
for name in "${FIGURES[@]}"; do
    log="logs/plot_${name}.log"
    echo "[master] --- $name"
    start=$SECONDS
    if bash "$name/plot.sh" > "$log" 2>&1; then
        echo "[master]     ok      ($((SECONDS - start))s)  log: $log"
        OK+=("$name")
    else
        status=$?
        echo "[master]     FAILED  (exit $status, $((SECONDS - start))s)  log: $log"
        echo "[master]     last lines:"
        tail -n 15 "$log" | sed -e 's/^/[master]     | /'
        FAILED+=("$name")
    fi
done

# -------------------------------- SUMMARY -----------------------------------
echo
echo "[master] done: ${#OK[@]} drawn, ${#FAILED[@]} failed"
if [ ${#FAILED[@]} -gt 0 ]; then
    echo "[master] failed: ${FAILED[*]}"
    echo "[master] full output in $HERE/logs/plot_<figure>.log"
    exit 1
fi
