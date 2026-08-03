#!/usr/bin/env bash
# allocate-resources.sh - Dynamic CI resource allocation for Stockfish
#
# Analyses the current git context (diff size, changed paths, event type,
# branch) and emits a set of GitHub Actions outputs that downstream jobs
# use to size the build matrix, parallelism, and cache strategy.
#
# Usage (local):
#   ./scripts/allocate-resources.sh [--event NAME] [--ref REF] [--base-strategy S]
#                                   [--pretty] [--github-output]
#
# Usage (Actions):
#   bash scripts/allocate-resources.sh --github-output
#
# Outputs (stdout compact key=value, or GITHUB_OUTPUT when requested):
#   strategy          aggressive | balanced | conservative
#   jobs              parallel make -j N
#   cache             aggressive | balanced | conservative
#   allocation        high-performance | balanced | standard | minimal
#   focus             nnue | search | engine | gui | docs | general
#   max-parallel      matrix max-parallel
#   fail-fast         true | false
#   estimated-jobs    number of matrix entries the allocator expects
#   reason            human-readable explanation (single line)
#
# Exit: 0 on success, 1 on usage error, 2 if jq missing when needed.

set -euo pipefail

EVENT="${GITHUB_EVENT_NAME:-push}"
REF="${GITHUB_REF:-refs/heads/master}"
BASE_STRATEGY="${MATRIX_BASE_STRATEGY:-auto}"
PRETTY=0
GITHUB_OUTPUT_MODE=0
BASE_SHA=""
HEAD_SHA="HEAD"

die() { echo "allocate-resources.sh: $*" >&2; exit 1; }

usage() {
  sed -n '2,35p' "$0" | sed 's/^# \?//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --event)          EVENT="$2"; shift 2 ;;
    --ref)            REF="$2"; shift 2 ;;
    --base-strategy)  BASE_STRATEGY="$2"; shift 2 ;;
    --base-sha)       BASE_SHA="$2"; shift 2 ;;
    --head-sha)       HEAD_SHA="$2"; shift 2 ;;
    --pretty)         PRETTY=1; shift ;;
    --github-output)  GITHUB_OUTPUT_MODE=1; shift ;;
    -h|--help)        usage ;;
    *)                die "unknown option: $1" ;;
  esac
done

resolve_base() {
  if [[ -n "$BASE_SHA" ]]; then
    echo "$BASE_SHA"
    return
  fi
  if [[ "$EVENT" == "pull_request" ]]; then
    local base_ref="${GITHUB_BASE_REF:-master}"
    if git rev-parse --verify "origin/${base_ref}" >/dev/null 2>&1; then
      git merge-base "origin/${base_ref}" HEAD 2>/dev/null || echo "HEAD~1"
      return
    fi
  fi
  if git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    echo "HEAD~1"
  else
    echo "HEAD"
  fi
}

BASE=$(resolve_base)
CHANGED_FILES=$(git diff --name-only "$BASE" "$HEAD_SHA" 2>/dev/null || true)
NUM_FILES=$(echo "$CHANGED_FILES" | grep -c . || true)
DIFFSTAT=$(git diff --shortstat "$BASE" "$HEAD_SHA" 2>/dev/null || echo "")
LINES_CHANGED=$(echo "$DIFFSTAT" | grep -oE '[0-9]+ insertion|[0-9]+ deletion' \
  | grep -oE '[0-9]+' | awk '{s+=$1} END {print s+0}' || true)
LINES_CHANGED=${LINES_CHANGED:-0}

has_path() { echo "$CHANGED_FILES" | grep -qE "$1" || return 1; }

FOCUS="general"
if has_path '^src/nnue/'; then
  FOCUS="nnue"
elif has_path '^src/search|^src/movepick|^src/tt\.|^src/thread'; then
  FOCUS="search"
elif has_path '^src/'; then
  FOCUS="engine"
elif has_path 'matrix-gui/|neuralchess-pwa/|Avalonia UI/'; then
  FOCUS="gui"
elif has_path '^docs/|^README|\.md$'; then
  FOCUS="docs"
fi

SCORE=50

case "$EVENT" in
  schedule)
    SCORE=$((SCORE + 45))
    ;;
  workflow_dispatch)  SCORE=$((SCORE + 15)) ;;
  push)
    if [[ "$REF" == "refs/heads/master" || "$REF" == "refs/heads/main" ]]; then
      SCORE=$((SCORE + 25))
    else
      SCORE=$((SCORE + 5))
    fi
    ;;
  pull_request)       SCORE=$((SCORE - 10)) ;;
  *)                  ;;
esac

if [[ "$NUM_FILES" -ge 40 || "$LINES_CHANGED" -ge 2000 ]]; then
  SCORE=$((SCORE + 20))
elif [[ "$NUM_FILES" -ge 15 || "$LINES_CHANGED" -ge 500 ]]; then
  SCORE=$((SCORE + 10))
elif [[ "$NUM_FILES" -le 2 && "$LINES_CHANGED" -le 50 ]]; then
  SCORE=$((SCORE - 15))
fi

case "$FOCUS" in
  nnue|search|engine) SCORE=$((SCORE + 10)) ;;
  gui)                SCORE=$((SCORE + 5))  ;;
  docs)               SCORE=$((SCORE - 20)) ;;
esac

case "$BASE_STRATEGY" in
  aggressive)   SCORE=$((SCORE + 25)) ;;
  conservative) SCORE=$((SCORE - 25)) ;;
  balanced)     ;;
  auto)         ;;
esac

[[ "$SCORE" -gt 100 ]] && SCORE=100
[[ "$SCORE" -lt 0   ]] && SCORE=0

if [[ "$SCORE" -ge 80 ]]; then
  STRATEGY="aggressive"
  JOBS=8
  CACHE="aggressive"
  ALLOCATION="high-performance"
  MAX_PARALLEL=4
  FAIL_FAST="false"
  ESTIMATED_JOBS=5
elif [[ "$SCORE" -ge 55 ]]; then
  STRATEGY="balanced"
  JOBS=4
  CACHE="balanced"
  ALLOCATION="balanced"
  MAX_PARALLEL=3
  FAIL_FAST="false"
  ESTIMATED_JOBS=3
elif [[ "$SCORE" -ge 35 ]]; then
  STRATEGY="balanced"
  JOBS=3
  CACHE="balanced"
  ALLOCATION="standard"
  MAX_PARALLEL=2
  FAIL_FAST="true"
  ESTIMATED_JOBS=2
else
  STRATEGY="conservative"
  JOBS=2
  CACHE="conservative"
  ALLOCATION="minimal"
  MAX_PARALLEL=1
  FAIL_FAST="true"
  ESTIMATED_JOBS=1
fi

if [[ "$EVENT" != "schedule" && "$FOCUS" == "docs" && "$NUM_FILES" -le 10 ]]; then
  STRATEGY="conservative"
  JOBS=2
  CACHE="conservative"
  ALLOCATION="minimal"
  MAX_PARALLEL=1
  FAIL_FAST="true"
  ESTIMATED_JOBS=1
fi

REASON="score=${SCORE} event=${EVENT} focus=${FOCUS} files=${NUM_FILES} lines~${LINES_CHANGED} base=${BASE_STRATEGY}"

emit() {
  if [[ $GITHUB_OUTPUT_MODE -eq 1 ]]; then
    [[ -n "${GITHUB_OUTPUT:-}" ]] || die "GITHUB_OUTPUT is not set"
    {
      echo "strategy=$STRATEGY"
      echo "jobs=$JOBS"
      echo "cache=$CACHE"
      echo "allocation=$ALLOCATION"
      echo "focus=$FOCUS"
      echo "max-parallel=$MAX_PARALLEL"
      echo "fail-fast=$FAIL_FAST"
      echo "estimated-jobs=$ESTIMATED_JOBS"
      echo "score=$SCORE"
      echo "reason=$REASON"
      echo "files-changed=$NUM_FILES"
      echo "lines-changed=$LINES_CHANGED"
    } >> "$GITHUB_OUTPUT"
    echo "allocate-resources.sh: $REASON -> allocation=$ALLOCATION jobs=$JOBS" >&2
  else
    cat <<EOF
strategy=$STRATEGY
jobs=$JOBS
cache=$CACHE
allocation=$ALLOCATION
focus=$FOCUS
max-parallel=$MAX_PARALLEL
fail-fast=$FAIL_FAST
estimated-jobs=$ESTIMATED_JOBS
score=$SCORE
reason=$REASON
files-changed=$NUM_FILES
lines-changed=$LINES_CHANGED
EOF
  fi
}

if [[ $PRETTY -eq 1 ]]; then
  cat <<EOF
+- Dynamic Resource Allocation -------------------------
| score            $SCORE / 100
| strategy         $STRATEGY
| allocation       $ALLOCATION
| parallel jobs    $JOBS
| max-parallel     $MAX_PARALLEL
| cache            $CACHE
| focus            $FOCUS
| fail-fast        $FAIL_FAST
| estimated matrix $ESTIMATED_JOBS jobs
| files changed    $NUM_FILES
| lines changed ~  $LINES_CHANGED
| event / ref      $EVENT / $REF
| base strategy    $BASE_STRATEGY
| reason           $REASON
+-------------------------------------------------------
EOF
fi

emit
