#!/bin/bash
# ============================================================================
# ONE evaluation script for every simulation of CORDEX-ML-Benchmark
#
# All the per-simulation evaluation.sh scripts do the same four (or five)
# things; they differ only in the PARAMETERS block. This is that script with
# the block lifted to the top, so a new contributor does not have to read 250
# lines of path plumbing to score their model.
#
# HOW TO USE IT
#   cp evaluation_master.sh .data/<YOUR_MODEL>/evaluation.sh
#   # set PROJECT (absolute project root) and SIMULATION, then
#   sbatch data/<YOUR_MODEL>/evaluation.sh
#
# WHAT IT COMPUTES (each track can be switched off in the PARAMETERS block)
#   fast      the 6 "hexagon" metrics, every VARIABLE            -> the skill scorecards
#   slow      spectral / distributional diagnostics, pr only     -> the pr scorecards
#   signal    climate-change delta, BOTH boundary cases          -> the signal scorecards
#   multivar  inter-VARIABLE correlation for a pair of VARIABLEs -> spatial_maps_multivarConsistency
#   prob      CRPS / Brier / spread-error, ensemble emulators    -> scorecard_triangle_prob
#
#
# Everything lands in this simulation's own outputs tree, under a run id that
# is the stem of the prediction file it describes:
#   data/<SIMULATION>/evaluation/<CHECKPOINT>_<rcm>_<train_gcm>_<DATASET>_<period>/<SEASON>/<VAR>/
#
# Run:   bash   evaluation_master.sh    (from anywhere)
#        sbatch evaluation_master.sh
#        DRY_RUN=1 below prints the ml-eval calls without running them.
# ============================================================================
#SBATCH --job-name=eval_DetUNet-orog
#SBATCH --output=./logs/evaluation-%x-%j.out
#SBATCH --error=./logs/evaluation-%x-%j.err
#SBATCH --partition=sci
#SBATCH --time=06:00:00
#SBATCH --mem=24GB

# --- Environment (must contain the ml-evaluation package: `ml-eval`) --------
source /nfs/home/gmeteo/casadoj/miniconda3/etc/profile.d/conda.sh
conda activate /nfs/home/gmeteo/casadoj/miniconda3/envs/ml-evaluation


# ###########################################################################
# #                            P A R A M E T E R S                          #
# #        Everything below this banner is what differs between models.      #
# ###########################################################################

# ============================ EDIT ME ======================================
# Absolute path to the CORDEX-ML-Bench project root. This is the ONE line to
# change if you work on a copy of the tree somewhere else.
PROJECT="/lustre/gmeteo/WORK/casadoj/ml-benchmark"
# ===========================================================================

# --- Which simulation ------------------------------------------------------
SIMULATION="DetUNet-orog"     # your directory under ./data/

# --- Which case ------------------------------------------------------------
VARS=("pr" "tasmax")
DOMAINS=("ALPS" "NZ" "SA")
TRAIN_EXPERIMENTS=("ESD_pseudo_reality" "Emulator_hist_future")
SEASON="annual"                 # annual, DJF, JJA, ...
OVERWRITE=0                     # 1 = recompute metrics that already exist
DRY_RUN=0                       # 1 = print the ml-eval calls, run none

# --- Which member ---------------------------------------------------
MEMBER=0                        # every track scores this member (prob keeps all of them)

# --- Which tracks to run ---------------------------------------------------
# Set to 0 to skip. PROB is for emulators whose sampler produces an ensemble 
DO_FAST=1
DO_SLOW=1
DO_SIGNAL=0
DO_MULTIVAR=0
DO_PROB=0                       # 1 for an ensemble emulator

# --- Track-specific settings -----------------------------------------------
# slow: 
SLOW_VARS=("pr" "tasmax")

# signal: 
HIST_HORIZON="historical"
FUTURE_HORIZON="mid_century"

# multivar: 
MV_PAIRS=("pr:tasmax")

# prob: 
PROB_FRAMEWORK="perfect"
PROB_HORIZON="mid_century"

# ###########################################################################
# #                    end of parameters -- plumbing below                  #
# ###########################################################################

DATA_DIR="$PROJECT/data"

cd "$PROJECT" || exit 1
[ "$SEASON" = "annual" ] && SEASON_FLAG="" || SEASON_FLAG="--season $SEASON"

run_eval() {
    local mode="$1"
    local first_option=1
    local index=0
    local -a args
    shift
    args=("$@")

    printf '\t+ ml-eval %q' "$mode"
    while [ "$((index + 1))" -lt "${#args[@]}" ]; do
        if [ "$first_option" -eq 1 ]; then
            printf ' %q %q' "${args[index]}" "${args[index + 1]}"
            first_option=0
        else
            printf ' \\\n\t\t\t%q %q' "${args[index]}" "${args[index + 1]}"
        fi
        index=$((index + 2))
    done
    if [ "$index" -lt "${#args[@]}" ]; then
        printf ' \\\n\t\t\t%q' "${args[index]}"
    fi
    printf '\n'

    [ "$DRY_RUN" = "1" ] && return 0
    ml-eval "$mode" "${args[@]}"
}

# No output leaf during a dry run: an empty run dir would be picked up by the figure scripts.
ensure_dir() { [ "$DRY_RUN" = "1" ] || mkdir -p "$1"; }

# Defines the RCM and GCM used for training and testing in the input domain.
#
#   Parameters
#   domain:     ALPS, SA (South Africa) or NZ (New Zealand)
#
#   Defines
#   rcm:        the Regional Climate Model used in that domain.
#   train_gcm:  the Global Climate Model used for training.
#   test_gcm:   the Global Climate Model used for testing in the imperfect framework.
define_rcm_gcm() {
    local domain="$1"

    case "$domain" in
        ALPS)
            rcm="CNRM-ALADIN63"
            train_gcm="CNRM-CM5"
            test_gcm="MPI-ESM-LR"
            ;;
        SA)
            rcm="CCAM"
            train_gcm="ACCESS-CM2"
            test_gcm="NorESM2-MM"
            ;;
        NZ)
            rcm="CCAM"
            train_gcm="ACCESS-CM2"
            test_gcm="EC-Earth3"
            ;;
        *)
            printf 'Unsupported domain for RCM/GCM configuration: %s\n' "$domain" >&2
            return 1
            ;;
    esac
}

# Returns the Global Climate Model to be used depending on the modelling framework.
# 
#   Parameters
#   framework:  "perfect" or "imperfect"
#   
#   Returns
#   A string with the Global Climate Model.
gcm_for_framework() {
    local framework="$1"

    case "$framework" in
        perfect)   printf '%s\n' "$train_gcm" ;;
        imperfect) printf '%s\n' "$test_gcm" ;;
        *)
            printf 'Unsupported framework: %s\n' "$framework" >&2
            return 1
            ;;
    esac
}

# Defines the list of test experiments corresponding to the training experiment: observational ESD or RCM emulator.
#
#   Parameters
#   train_exp:  name of the training experiment
# 
#   Defines
#   test_experiments:   a list of the available tests for the input training experiment.
#
# TODO: add imperfect experiments
define_tests() {
    local train_exp="$1"

    case "$train_exp" in
        ESD_pseudo_reality)
            test_experiments=("Perfect_cross_validation" "Perfect_extrapolation")
            ;;
        Emulator_hist_future)
            test_experiments=("Perfect_cross_validation" "Perfect_interpolation")
            ;;
        *)
            printf 'Unsupported training experiment: %s\n' "$train_exp" >&2
            return 1
            ;;
    esac

}

# Sets horizon, framework, and period for the training/test experiment pair.
#
#   Parameters
#   train_exp:  name of the training experiment
#   test_exp:   name of the test experiment
#
#   Defines
#   horizon:    either "historical", "mid_century" or "end_century"
#   framework:  "perfect" or "imperfect"
#   period:     years associated with the horizon: 1981-2000, 2041-2060, 2081-2099
setup_test() {
    local train_exp="$1"
    local test_exp="$2"

    horizon=""
    framework=""
    period=""

    case "$train_exp:$test_exp" in
        ESD_pseudo_reality:Perfect_cross_validation)
            horizon="historical"
            framework="perfect"
            ;;
        ESD_pseudo_reality:Imperfect_cross_validation)
            horizon="historical"
            framework="imperfect"
            ;;
        ESD_pseudo_reality:Perfect_extrapolation|\
        ESD_pseudo_reality:Perfect_extrapolation_GCM_transferability)
            horizon="mid_century" #(mid_century end_century)
            framework="perfect"
            ;;
        ESD_pseudo_reality:Imperfect_extrapolation)
            horizon="mid_century" #(mid_century end_century)
            framework="imperfect"
            ;;
        Emulator_hist_future:Perfect_cross_validation)
            horizon="historical"
            framework="perfect"
            ;;
        Emulator_hist_future:Imperfect_cross_validation)
            horizon="historical"
            framework="imperfect"
            ;;
        Emulator_hist_future:Perfect_interpolation|\
        Emulator_hist_future:Perfect_interpolation_GCM_transferability)
            horizon="mid_century"
            framework="perfect"
            ;;
        Emulator_hist_future:Imperfect_interpolation|\
        Emulator_hist_future:Imperfect_interpolation_GCM_transferability)
            horizon="mid_century"
            framework="imperfect"
            ;;
        *)
            printf 'Unsupported training/evaluation combination: %s / %s\n' \
                "$train_exp" "$test_exp" >&2
            return 1
            ;;
    esac

    # period="$(period_for_horizon "$horizon")" || return 1
}

# Returns the start and end year for a given temporal horizon.
#
#   Parameters
#   horizon:    "historical", "mid_century" or "end_century"
#
#   Returns
#   A string in the format "<start_year>-<end_year>"
period_for_horizon() {
    local horizon="$1"
    
    local period
    case "$horizon" in
        historical)   period="1981-2000" ;;
        mid_century)  period="2041-2060" ;;
        end_century)  period="2080-2099" ;;
        *)
            printf 'Unsupported horizon: %s\n' "$horizon" >&2
            return 1
            ;;
    esac

    printf '%s\n' "$period"
}

# Returns the Regional Climate Model reference NetCDF file.
#
#   Parameters
#   horizon:    "historical", "mid_century" or "end_century"
#   framework:  "perfect" or "imperfect"
#
#   Returns
#   A string of the NetCDF reference file.
rcm_file() {
    local horizon="$1"
    local framework="$2"
    local period

    period="$(period_for_horizon "$horizon")" || return 1
    gcm="$(gcm_for_framework "$framework")" || return 1

    printf '%s\n' \
        "$DATA_DIR/target/${domain}_domain/test/$horizon/target/pr_tasmax_${gcm}_${period}.nc"
}

# Returns the prediction NetCDF file.
#
#   Parameters
#   horizon:    "historical", "mid_century" or "end_century"
#   framework:  "perfect" or "imperfect"
#
#   Returns
#   A string of the NetCDF prediction file.
pred_file() {
    local horizon="$1"
    local framework="$2"
    local period

    period="$(period_for_horizon "$horizon")" || return 1
    gcm="$(gcm_for_framework "$framework")" || return 1

    printf '%s\n' \
        "$DATA_DIR/$SIMULATION/predictions/${domain}_Domain/$train_exp/$horizon/$framework/Predictions_pr_tasmax_${gcm}_${period}.nc"
}

# Returns the directory where results will be saved.
#
#   Parameters
#   var:        variable
#
#   Returns
#   A string with the output directory.
# eval_dir() {
#     local variable="$1"
#     printf '%s\n' \
#         "$DATA_DIR/$SIMULATION/evaluation/${domain}_Domain/$train_exp/$test_exp/$variable/"
# }

# Returns the directory where results will be saved.
#
#   Parameters
#   horizon:    "historical", "mid_century" or "end_century"
#   framework:  "perfect" or "imperfect"    
#   variable:   
#
#   Returns
#   A string with the output directory.
eval_dir() {
    local horizon="$1"
    local framework="$2"
    local variable="$3"

    period="$(period_for_horizon "$horizon")" || return 1
    gcm="$(gcm_for_framework "$framework")" || return 1

    printf '%s\n' \
        "$DATA_DIR/$SIMULATION/evaluation/${domain}_Domain/${train_exp}/${rcm}_${train_gcm}_${gcm}_${period}/$SEASON/$variable/"
}

have() { [ "$OVERWRITE" != "1" ] && [ -e "$1/$2" ]; }

echo "[eval] project    = $PROJECT"
echo "[eval] simulation = $SIMULATION"
echo "[eval] tracks     = fast:$DO_FAST slow:$DO_SLOW signal:$DO_SIGNAL multivar:$DO_MULTIVAR prob:$DO_PROB"
[ "$DRY_RUN" = "1" ] && echo "[eval] DRY RUN -- no metrics will be written"
echo

for domain in "${DOMAINS[@]}"; do

    if ! define_rcm_gcm "$domain"; then
        exit 1
    fi

    for train_exp in "${TRAIN_EXPERIMENTS[@]}"; do
        define_tests $train_exp

        for test_exp in "${test_experiments[@]}"; do

            setup_test $train_exp $test_exp
            gcm="$(gcm_for_framework "$framework")"
            echo "[eval] $domain domain | train=$train_exp | test=$test_exp | framework=$framework ($gcm) | period=$horizon"

            ref="$(rcm_file "$horizon" "$framework")"
            if [ ! -f "$ref" ]; then
                echo "[eval] ABORT: reference not found: $ref" >&2
                exit 1
            fi
            
            pred="$(pred_file "$horizon" "$framework")"


            # ============================ FAST EVALUATION ==============================
            # The 6 "hexagon" metrics: reference (x0) vs prediction (x1) at period.
            if [ "$DO_FAST" = "1" ]; then
                if [ ! -f "$pred" ]; then
                    echo "[fast] SKIP: prediction not found: $pred" >&2
                else
                    for var in "${VARS[@]}"; do
                        out_dir="$(eval_dir "$horizon" "$framework" "$var")"
                        ensure_dir "$out_dir"
                        echo "[fast] START: computing fast evaluation for '$var'..."
                        run_eval fast --x0 "$ref" --x1 "$pred" --var "$var" --output "$out_dir" \
                                    --member-num "$MEMBER" $SEASON_FLAG
                    done
                fi
            fi


            # ============================== SLOW EVALUATION ============================
            # The expensive spectral / distributional diagnostics (PSD, RALSD, spatial
            # Wasserstein) for SLOW_VARS only. Same reference and prediction as the fast
            # track, and the metrics land in the same leaf dir.
            if [ "$DO_SLOW" = "1" ]; then
                if [ ! -f "$pred" ]; then
                    echo "[slow] SKIP: prediction not found: $pred" >&2
                else
                    for var in "${SLOW_VARS[@]}"; do
                        out_dir="$(eval_dir "$horizon" "$framework" "$var")"
                        have "$out_dir" metrics_slow_field.zarr && {
                            echo "[slow] SKIP: $var already exists (set OVERWRITE=1 to recompute)"; continue; }
                        ensure_dir "$out_dir"
                        echo "[slow] START; computing slow evaluation for '$var'..."
                        run_eval slow --x0 "$ref" --x1 "$pred" --var "$var" --output "$out_dir" \
                                    --member-num "$MEMBER" $SEASON_FLAG
                    done
                fi
            fi


            # ======================= CLIMATE-CHANGE SIGNAL =============================
            # delta = future - historical, per source, from MEMBER (as every other track).
            # Unlike the tracks above -- which score the single framework selected in the 
            # parameters -- the signal is computed for BOTH boundary cases, because perfect
            # vs imperfect is the contrast the signal scorecards draw. Each case writes
            # under its own run id (only the <gcm> field differs), so the scorecard reads 
            # both with the identical layout.
            if [ "$DO_SIGNAL" = "1" ]; then
                if [ "$horizon" != "$FUTURE_HORIZON" ]; then
                    echo "[signal] SKIP: Climate Change signal is not computed for the $horizon horizon."
                else
                    pred_fut="$(pred_file "$horizon" "$framework")"
                    pred_hist="$(pred_file "$HIST_HORIZON" "$framework")"
                    for var in "${VARS[@]}"; do
                        # Both periods must exist: the dir is only created once they do, so a
                        # missing case leaves no empty run dir for the scorecard to pick up.
                        if [ ! -f "$pred_hist" ] || [ ! -f "$pred_fut" ]; then
                            echo "[signal] SKIP $framework | $var: missing prediction ($pred_hist or $pred_fut)"
                            continue
                        fi
                        out_dir="$(eval_dir "$horizon" "$framework" "$var")"
                        ensure_dir "$out_dir"
                        echo "[signal] START: computing Climate Change signal (${HIST_HORIZON}-${horizon}) for '$var'..."
                        run_eval signal --hist "$pred_hist" --fut "$pred_fut" --var "$var" --output "$out_dir" \
                                        --member-num "$MEMBER" $SEASON_FLAG
                    done
                fi
            fi


            # ==================== MULTIVARIATE CONSISTENCY =============================
            # The correlation between a PAIR of predicted VARIABLEs, for the truth and for
            # this emulator, plus the bias between them. Every other track scores one
            # VARIABLE at a time, so a model can be right on each separately while getting
            # their relationship wrong -- this is the track that notices.
            if [ "$DO_MULTIVAR" = "1" ]; then
                if [ ! -f "$pred" ]; then
                    echo "[multivar] SKIP: prediction not found: $pred" >&2
                else
                    for pair in "${MV_PAIRS[@]}"; do
                        v1="${pair%%:*}"; v2="${pair##*:}"
                        out_dir="$(eval_dir "$horizon" "$framework" "${v1}_${v2}")"
                        have "$out_dir" metrics_mv_field.zarr && {
                            echo "[multivar] SKIP: ${v1}-${v2} already exists (set OVERWRITE=1 to recompute)"; continue; }
                        ensure_dir "$out_dir"
                        echo "[multivar] START: computing multivariate evaluation for ${v1}-${v2}..."
                        run_eval multivar --x0 "$ref" --x1 "$pred" --var "$v1" --var2 "$v2" \
                                        --output "$out_dir" --member-num "$MEMBER" $SEASON_FLAG
                    done
                fi
            fi


            # ====================== PROBABILISTIC EVALUATION ===========================
            # CRPS, Brier score and spread-error ratio: the only track that consumes every
            # member at once (no --member-num -- `ml-eval prob` keeps the member dimension
            # by construction). Metrics land in the SAME leaf as the fast/slow ones, as
            # metrics_prob_{field,float}.zarr, which FIGURES/scorecard_triangle_prob reads.
            if [ "$DO_PROB" = "1" ]; then
                if [ "$horizon" != "$PROB_HORIZON" ]; then
                    echo "[prob] SKIP: the probabilistic evaluation is not computed for the $horizon horizon."
                elif [ "$framework" != "$PROB_FRAMEWORK" ]; then
                    echo "[prob] SKIP: the probabilistic evaluation is not computed for the $framework framework."
                else
                    pred_prob="$(pred_file "$horizon" "$framework")"
                        if [ ! -f "$pred_prob" ]; then
                            echo "[prob] SKIP: prediction not found: $pred_prob" >&2
                        else
                            for var in "${VARS[@]}"; do
                                out_dir="$(eval_dir "$horizon" "$framework" "$var")"
                                have "$out_dir" metrics_prob_field.zarr && {
                                    echo "[prob] SKIP: $var already exists (set OVERWRITE=1 to recompute)"; continue; }
                                ensure_dir "$out_dir"
                                echo "[prob] START: computing probabilistic evaluation for '$var'..."
                                run_eval prob --x0 "$ref" --x1 "$pred_prob" --var "$var" --output "$out_dir" $SEASON_FLAG
                            done
                        fi
                fi
            fi

            echo "[eval] FINISHED: $test_exp test experiment"
            echo

        done

        echo "[eval] FINISHED: $train_exp train experiment"
        echo

    done

    echo "[eval] FINISHED: $domain -> Results: $DATA_DIR/$SIMULATION/evaluation/${domain}_Domain/"
    echo

done

echo "[eval] FINISHED: $SIMULATION -> Results: $DATA_DIR/$SIMULATION/evaluation/"

