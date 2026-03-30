#!/usr/bin/env bash
# =============================================================
# run_pa4.sh – PA4 Data Pipeline for NBA TeamStatistics
# Usage: bash run_pa4.sh <INPUT_CSV>
# =============================================================
set -euo pipefail

# ── Resolve paths relative to this script ─────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Argument check ────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <INPUT_CSV>" >&2
    echo "  e.g. $0 data/TeamStatistics.csv" >&2
    exit 1
fi

INPUT="$1"

# ── Validate input ────────────────────────────────────────────
if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: file not found: $INPUT" >&2
    exit 2
fi

if [[ ! -r "$INPUT" ]]; then
    echo "ERROR: file not readable: $INPUT" >&2
    exit 2
fi

# Ensure group-readable if possible (non-fatal)
chmod -R g+rX "$INPUT" 2>/dev/null || true

# ── Create output directories ─────────────────────────────────
OUT="out"
LOGS="logs"
mkdir -p "$OUT" "$LOGS"

LOG="$LOGS/pa4_run.log"
ERR="$LOGS/pa4_errors.log"
: > "$LOG"
: > "$ERR"

# Tee stdout to log, stderr to error log
exec > >(tee -a "$LOG") 2> >(tee -a "$ERR" >&2)

echo "=== PA4 Pipeline Start ==="
echo "Date: $(date)"
echo "Input: $INPUT"
echo "Rows:  $(wc -l < "$INPUT")"
echo

# ==============================================================
# STEP 1: CLEAN AND NORMALIZE (SED)
# ==============================================================
echo "--- Step 1: SED cleaning & normalization ---"

CLEANED="$OUT/cleaned.tsv"

# Save a small "before" sample (first 6 lines, raw)
head -n 6 "$INPUT" > "$OUT/before_clean_sample.csv"

sed -E '
    # 1) Strip trailing carriage returns (Windows line endings)
    s/\r$//

    # 2) Trim leading whitespace from the line
    s/^[[:space:]]+//

    # 3) Trim trailing whitespace from the line
    s/[[:space:]]+$//

    # 4) Remove trailing comma (artifact from CSV export)
    s/,$//

    # 5) Normalize empty fields between commas to NA
    #    Repeat to catch consecutive empty fields
    s/,,/,NA,/g
    s/,,/,NA,/g

    # 6) Normalize leading empty field
    s/^,/NA,/

    # 7) Normalize trailing empty field
    s/,$/,NA/

    # 8) Collapse multiple internal spaces within fields to single space
    s/  +/ /g

    # 9) Convert comma delimiter to tab for downstream AWK processing
    s/,/\t/g
' "$INPUT" > "$CLEANED"

# Save a small "after" sample (first 6 lines, cleaned)
head -n 6 "$CLEANED" > "$OUT/after_clean_sample.tsv"

echo "Cleaned TSV written to $CLEANED"
echo "Before/after samples saved."
echo

# ==============================================================
# STEP 2: QUALITY FILTERS (AWK)
# ==============================================================
echo "--- Step 2: AWK quality filters ---"

FILTERED="$OUT/filtered.tsv"

# Column indices in the cleaned TSV (1-based):
# 1=gameId, 2=gameDateTimeEst, 3=teamCity, 4=teamName, 5=teamId,
# 6=opponentTeamCity, 7=opponentTeamName, 8=opponentTeamId,
# 9=home, 10=win, 11=teamScore, 12=opponentScore,
# 13=assists, 14=blocks, 15=steals, 16=fieldGoalsAttempted,
# 17=fieldGoalsMade, 18=fieldGoalsPercentage,
# 19=threePointersAttempted, 20=threePointersMade,
# 21=threePointersPercentage, 22=freeThrowsAttempted,
# 23=freeThrowsMade, 24=freeThrowsPercentage,
# 25=reboundsDefensive, 26=reboundsOffensive, 27=reboundsTotal,
# 28=foulsPersonal, 29=turnovers, 30=plusMinusPoints,
# 31=numMinutes, 32=q1Points, 33=q2Points, 34=q3Points,
# 35=q4Points, 36=benchPoints, 37=biggestLead,
# 38=biggestScoringRun, 39=leadChanges, 40=pointsFastBreak,
# 41=pointsFromTurnovers, 42=pointsInThePaint,
# 43=pointsSecondChance, 44=timesTied, 45=timeoutsRemaining,
# 46=seasonWins, 47=seasonLosses, 48=coachId

awk -F'\t' -v OFS='\t' '
    # Always keep header
    NR == 1 { print; next }

    # Filter rules:
    #   - teamName must be non-empty and not NA
    #   - teamScore must be numeric and > 0
    #   - opponentScore must be numeric and > 0
    #   - win must be 0 or 1
    #   - fieldGoalsAttempted must be numeric and > 0 (sanity check)
    #   - gameDateTimeEst must not be NA
    $4 != "" && $4 != "NA" &&
    $11 ~ /^[0-9]+$/ && $11 + 0 > 0 &&
    $12 ~ /^[0-9]+$/ && $12 + 0 > 0 &&
    ($10 == "0" || $10 == "1") &&
    $16 ~ /^[0-9]+$/ && $16 + 0 > 0 &&
    $2 != "NA" {
        print
    }
' "$CLEANED" > "$FILTERED"

TOTAL_RAW=$(awk 'END{print NR-1}' "$CLEANED")
TOTAL_FILT=$(awk 'END{print NR-1}' "$FILTERED")
DROPPED=$((TOTAL_RAW - TOTAL_FILT))

echo "Rows before filter: $TOTAL_RAW"
echo "Rows after filter:  $TOTAL_FILT"
echo "Rows dropped:       $DROPPED"

# Save a small filtered sample
head -n 11 "$FILTERED" > "$OUT/filtered_sample.tsv"
echo "Filtered sample saved."
echo

# ==============================================================
# STEP 3: RATIOS, BUCKETS, AND PER-ENTITY SUMMARIES (AWK)
# ==============================================================
echo "--- Step 3: Ratios, buckets, per-team summaries ---"

# 3a) Three-point shooting ratio with bucketization
awk -F'\t' -v OFS='\t' '
BEGIN {
    print "teamName\tgameDate\t3PA\t3PM\t3P_pct\tbucket"
}
NR == 1 { next }
{
    team = $4
    dt   = $2
    tpa  = $19 + 0  # threePointersAttempted
    tpm  = $20 + 0  # threePointersMade

    # Guard against division by zero
    if (tpa > 0)
        pct = tpm / tpa
    else
        pct = 0.0

    # Bucketize shooting percentage
    if (tpa == 0)
        bucket = "ZERO_ATT"
    else if (pct >= 0.40)
        bucket = "HI"
    else if (pct >= 0.30)
        bucket = "MID"
    else
        bucket = "LO"

    printf "%s\t%s\t%d\t%d\t%.3f\t%s\n", team, dt, tpa, tpm, pct, bucket
}
' "$FILTERED" > "$OUT/three_point_ratios.tsv"

echo "Three-point ratios with buckets saved."

# 3b) Bucket distribution counts
{
    printf "bucket\tcount\n"
    awk -F'\t' '
    NR == 1 { next }
    { cnt[$6]++ }
    END {
        for (b in cnt) printf "%s\t%d\n", b, cnt[b]
    }
    ' "$OUT/three_point_ratios.tsv" | sort -t$'\t' -k2 -rn
} > "$OUT/bucket_distribution.tsv"

echo "Bucket distribution:"
cat "$OUT/bucket_distribution.tsv"
echo

# 3c) Per-team summary: games, avg points, avg 3P%, avg assists, wins, win%
{
    printf "team\tgames\tavg_pts\tavg_ast\tavg_3pct\twins\twin_pct\n"
    awk -F'\t' -v OFS='\t' '
    NR == 1 { next }
    {
        team = $4
        score = $11 + 0
        win   = $10 + 0
        ast   = $13 + 0
        tpa   = $19 + 0
        tpm   = $20 + 0

        games[team]++
        total_pts[team]  += score
        total_win[team]  += win
        total_ast[team]  += ast
        total_tpa[team]  += tpa
        total_tpm[team]  += tpm
    }
    END {
        for (t in games) {
            avg_pts  = total_pts[t] / games[t]
            avg_ast  = total_ast[t] / games[t]
            avg_3pct = (total_tpa[t] > 0) ? total_tpm[t] / total_tpa[t] : 0
            win_pct  = total_win[t] / games[t]
            printf "%s\t%d\t%.1f\t%.1f\t%.3f\t%d\t%.3f\n", \
                t, games[t], avg_pts, avg_ast, avg_3pct, total_win[t], win_pct
        }
    }
    ' "$FILTERED" | sort -t$'\t' -k1,1
} > "$OUT/per_team_summary.tsv"

echo "Per-team summary saved."
echo

# ==============================================================
# STEP 4: TEMPORAL ANALYSIS – Monthly aggregation
# ==============================================================
echo "--- Step 4: Temporal analysis (monthly) ---"

awk -F'\t' -v OFS='\t' '
NR == 1 { next }
{
    # Extract YYYY-MM from gameDateTimeEst (field 2)
    # Format: "2026-03-09 22:00:00" -> "2026-03"
    dt = $2
    if (length(dt) < 7) next
    ym = substr(dt, 1, 7)
    # Validate format YYYY-MM
    if (ym !~ /^[0-9]{4}-[0-9]{2}$/) next

    score = $11 + 0
    win   = $10 + 0
    tpm   = $20 + 0
    ast   = $13 + 0

    cnt[ym]++
    tot_pts[ym]  += score
    tot_win[ym]  += win
    tot_3pm[ym]  += tpm
    tot_ast[ym]  += ast
}
END {
    print "month\tgames\tavg_pts\tavg_3pm\tavg_ast\twin_pct"
    for (ym in cnt) {
        g = cnt[ym]
        printf "%s\t%d\t%.1f\t%.1f\t%.1f\t%.3f\n", \
            ym, g, tot_pts[ym]/g, tot_3pm[ym]/g, tot_ast[ym]/g, tot_win[ym]/g
    }
}
' "$FILTERED" > "$OUT/monthly_trends_unsorted.tsv"

# Sort by month (chronologically), keeping header
head -1 "$OUT/monthly_trends_unsorted.tsv" > "$OUT/monthly_trends.tsv"
tail -n +2 "$OUT/monthly_trends_unsorted.tsv" | sort -t$'\t' -k1,1 >> "$OUT/monthly_trends.tsv"
rm -f "$OUT/monthly_trends_unsorted.tsv"

echo "Monthly trends saved."
head -n 12 "$OUT/monthly_trends.tsv"
echo

# ==============================================================
# STEP 5: SIGNAL DISCOVERY – Numeric distribution & z-score outliers
# ==============================================================
echo "--- Step 5: Signal discovery ---"

# 5a) Distribution profiles for key numeric columns
awk -F'\t' -v OFS='\t' '
NR == 1 { next }
{
    # Collect numeric columns: teamScore(11), assists(13), blocks(14),
    # steals(15), turnovers(29), reboundsTotal(27), threePointersMade(20)
    n_pts++;  s_pts  += $11; ss_pts  += $11*$11
    if (n_pts==1 || $11+0 < min_pts) min_pts=$11+0
    if (n_pts==1 || $11+0 > max_pts) max_pts=$11+0

    n_ast++;  s_ast  += $13; ss_ast  += $13*$13
    if (n_ast==1 || $13+0 < min_ast) min_ast=$13+0
    if (n_ast==1 || $13+0 > max_ast) max_ast=$13+0

    n_blk++;  s_blk  += $14; ss_blk  += $14*$14
    if (n_blk==1 || $14+0 < min_blk) min_blk=$14+0
    if (n_blk==1 || $14+0 > max_blk) max_blk=$14+0

    n_stl++;  s_stl  += $15; ss_stl  += $15*$15
    if (n_stl==1 || $15+0 < min_stl) min_stl=$15+0
    if (n_stl==1 || $15+0 > max_stl) max_stl=$15+0

    n_tov++;  s_tov  += $29; ss_tov  += $29*$29
    if (n_tov==1 || $29+0 < min_tov) min_tov=$29+0
    if (n_tov==1 || $29+0 > max_tov) max_tov=$29+0

    n_reb++;  s_reb  += $27; ss_reb  += $27*$27
    if (n_reb==1 || $27+0 < min_reb) min_reb=$27+0
    if (n_reb==1 || $27+0 > max_reb) max_reb=$27+0

    n_3pm++;  s_3pm  += $20; ss_3pm  += $20*$20
    if (n_3pm==1 || $20+0 < min_3pm) min_3pm=$20+0
    if (n_3pm==1 || $20+0 > max_3pm) max_3pm=$20+0
}
function print_stat(name, n, s, ss, mn, mx) {
    if (n > 1) {
        mean = s / n
        var  = (ss - s*s/n) / (n-1)
        std  = sqrt(var > 0 ? var : 0)
        printf "%s\t%d\t%.2f\t%.2f\t%.0f\t%.0f\n", name, n, mean, std, mn, mx
    }
}
END {
    printf "stat\tcount\tmean\tstd\tmin\tmax\n"
    print_stat("teamScore",       n_pts, s_pts, ss_pts, min_pts, max_pts)
    print_stat("assists",         n_ast, s_ast, ss_ast, min_ast, max_ast)
    print_stat("blocks",          n_blk, s_blk, ss_blk, min_blk, max_blk)
    print_stat("steals",          n_stl, s_stl, ss_stl, min_stl, max_stl)
    print_stat("turnovers",       n_tov, s_tov, ss_tov, min_tov, max_tov)
    print_stat("reboundsTotal",   n_reb, s_reb, ss_reb, min_reb, max_reb)
    print_stat("threePointersMade", n_3pm, s_3pm, ss_3pm, min_3pm, max_3pm)
}
' "$FILTERED" > "$OUT/distribution_profiles.tsv"

echo "Distribution profiles:"
cat "$OUT/distribution_profiles.tsv"
echo

# 5b) Win-rate comparison by category: home vs away
awk -F'\t' -v OFS='\t' '
NR == 1 { next }
{
    loc = ($9 == "1") ? "Home" : "Away"
    games[loc]++
    wins[loc] += ($10 + 0)
    pts[loc]  += ($11 + 0)
    ast[loc]  += ($13 + 0)
    tpm[loc]  += ($20 + 0)
}
END {
    print "location\tgames\twin_pct\tavg_pts\tavg_ast\tavg_3pm"
    # Print in deterministic order (Away, Home) instead of hash iteration
    split("Away Home", order, " ")
    for (i = 1; i <= 2; i++) {
        loc = order[i]
        if (games[loc] > 0) {
            g = games[loc]
            printf "%s\t%d\t%.3f\t%.1f\t%.1f\t%.1f\n", \
                loc, g, wins[loc]/g, pts[loc]/g, ast[loc]/g, tpm[loc]/g
        }
    }
}
' "$FILTERED" > "$OUT/home_away_comparison.tsv"

echo "Home vs Away comparison:"
cat "$OUT/home_away_comparison.tsv"
echo

# 5c) Outlier detection: flag games where teamScore z-score > 2.5
{
    printf "teamName\tdate\tscore\tz_score\n"
    awk -F'\t' '
    NR == 1 { next }
    { scores[NR] = $11+0; teams[NR] = $4; dates[NR] = $2; n++; sum += $11+0; sumsq += ($11+0)^2 }
    END {
        mean = sum / n
        std  = sqrt((sumsq - sum*sum/n) / (n-1))
        for (i in scores) {
            z = (scores[i] - mean) / std
            if (z > 2.5 || z < -2.5)
                printf "%s\t%s\t%d\t%.2f\n", teams[i], dates[i], scores[i], z
        }
    }
    ' "$FILTERED" | sort -t$'\t' -k4 -rn
} > "$OUT/score_outliers.tsv"

OUTLIER_CNT=$(awk 'END{print NR-1}' "$OUT/score_outliers.tsv")
echo "Score outliers (|z| > 2.5): $OUTLIER_CNT games"
head -n 11 "$OUT/score_outliers.tsv"
echo

# 5d) Ranked signals table: per-team offensive efficiency (pts + ast per turnover)
{
    printf "rank\tteam\tgames\tavg_pts\tavg_ast\tavg_tov\toffensive_efficiency\n"
    awk -F'\t' -v OFS='\t' '
    NR == 1 { next }
    {
        team = $4
        games[team]++
        pts[team] += $11 + 0
        ast[team] += $13 + 0
        tov[team] += $29 + 0
    }
    END {
        for (t in games) {
            g = games[t]
            ap = pts[t]/g
            aa = ast[t]/g
            at = tov[t]/g
            # Offensive efficiency: (points + assists) / turnovers
            eff = (at > 0) ? (ap + aa) / at : 0
            printf "%s\t%d\t%.1f\t%.1f\t%.1f\t%.2f\n", t, g, ap, aa, at, eff
        }
    }
    ' "$FILTERED" | sort -t$'\t' -k6 -rn | awk -F'\t' -v OFS='\t' '
    { printf "%d\t%s\n", NR, $0 }
    '
} > "$OUT/offensive_efficiency_ranked.tsv"

echo "Top 10 teams by offensive efficiency:"
head -n 11 "$OUT/offensive_efficiency_ranked.tsv"
echo

# ==============================================================
# Done
# ==============================================================
echo "=== PA4 Pipeline Complete ==="
echo "Date: $(date)"
echo "All outputs in: $OUT/"
echo "Logs in:        $LOGS/"
echo
echo "Output files:"
ls -1 "$OUT"/*.tsv "$OUT"/*.csv 2>/dev/null | sed "s|^|  |"
