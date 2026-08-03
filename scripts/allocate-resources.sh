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
# Exit codes:
#   0  success (always emits a usable allocation; soft failures are warned)
#   1  usage / validation error (bad flags or enum values)
#   2  environment error (e.g. GITHUB_OUTPUT required but unset)

set -euo pipefail

SCRIPT_NAME="allocate-resources.sh"
_WARNINGS=0

log()  { printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2; }
warn() { log "WARNING: $*"; _WARNINGS=$((_WARNINGS + 1)); }
die()  { log "ERROR: $*"; exit 1; }
die_env() { log "ERROR: $*"; exit 2; }

_on_err() {
  local exit_code=$?
  local line="${1:-?}"
  warn "unexpected error at line ${line} (exit ${exit_code}); applying safe fallback allocation"
  STRATEGY="conservative"
  JOBS=2
  CACHE="conservative"
  ALLOCATION="minimal"
  FOCUS="${FOCUS:-general}"
  MAX_PARALLEL=1
  FAIL_FAST="true"
  ESTIMATED_JOBS=1
  SCORE="${SCORE:-0}"
  NUM_FILES="${NUM_FILES:-0}"
  LINES_CHANGED="${LINES_CHANGED:-0}"
  REASON="fallback:error-at-line-${line}"
  emit || true
  exit 0
}
trap '_on_err $LINENO' ERR

usage() {
  sed -n '2,40p' "$0" | sed 's/^# \?//'
  exit 0
}

need_arg() {
  local opt="$1"
  local val="${2:-}"
  if [[ -z "$val" || "$val" == --* ]]; then
    die "option ${opt} requires a value"
  fi
}

validate_enum() {
  local name="$1"
  local value="$2"
  shift 2
  local allowed=("$@")
  local a
  for a in "${allowed[@]}"; do
    if [[ "$value" == "$a" ]]; then
      return 0
    fi
  done
  die "invalid ${name}='${value}' (allowed: ${allowed[*]})"
}

EVENT="${GITHUB_EVENT_NAME:-push}"
REF="${GITHUB_REF:-refs/heads/master}"
BASE_STRATEGY="${MATRIX_BASE_STRATEGY:-auto}"
PRETTY=0
GITHUB_OUTPUT_MODE=0
BASE_SHA=""
HEAD_SHA="HEAD"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --event)
      need_arg "$1" "${2:-}"
      EVENT="$2"
      shift 2
      ;;
    --ref)
      need_arg "$1" "${2:-}"
      REF="$2"
      shift 2
      ;;
    --base-strategy)
      need_arg "$1" "${2:-}"
      BASE_STRATEGY="$2"
      shift 2
      ;;
    --base-sha)
      need_arg "$1" "${2:-}"
      BASE_SHA="$2"
      shift 2
      ;;
    --head-sha)
      need_arg "$1" "${2:-}"
      HEAD_SHA="$2"
      shift 2
      ;;
    --pretty)
      PRETTY=1
      shift
      ;;
    --github-output)
      GITHUB_OUTPUT_MODE=1
      shift
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      die "unexpected argument: $1 (try --help)"
      ;;
  esac
done

validate_enum "event" "$EVENT" \
  push pull_request schedule workflow_dispatch release workflow_run
validate_enum "base-strategy" "$BASE_STRATEGY" \
  auto aggressive balanced conservative

if [[ -n "$BASE_SHA" && ! "$BASE_SHA" =~ ^[0-9a-fA-F]{7,40}$ && "$BASE_SHA" != HEAD* ]]; then
  warn "base-sha '${BASE_SHA}' does not look like a git revision; continuing anyway"
fi

IN_GIT_REPO=0
if command -v git >/dev/null 2>&1; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IN_GIT_REPO=1
  else
    warn "not inside a git work tree; diff analysis will be skipped"
  fi
else
  warn "git is not available; diff analysis will be skipped"
fi

resolve_base() {
  if [[ -n "$BASE_SHA" ]]; then
    printf '%s\n' "$BASE_SHA"
    return 0
  fi
  if [[ "$IN_GIT_REPO" -ne 1 ]]; then
    printf 'HEAD\n'
    return 0
  fi
  if [[ "$EVENT" == "pull_request" ]]; then
    local base_ref="${GITHUB_BASE_REF:-master}"
    if git rev-parse --verify "origin/${base_ref}" >/dev/null 2>&1; then
      git merge-base "origin/${base_ref}" HEAD 2>/dev/null || printf 'HEAD~1\n'
      return 0
    fi
    warn "could not resolve origin/${base_ref} for PR base; falling back to HEAD~1"
  fi
  if git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    printf 'HEAD~1\n'
  else
    printf 'HEAD\n'
  fi
}

BASE="$(resolve_base)"
CHANGED_FILES=""
NUM_FILES=0
LINES_CHANGED=0
DIFFSTAT=""

if [[ "$IN_GIT_REPO" -eq 1 ]]; then
  if ! CHANGED_FILES="$(git diff --name-only "$BASE" "$HEAD_SHA" 2>/dev/null)"; then
    warn "git diff --name-only failed (base=${BASE} head=${HEAD_SHA}); treating as no changes"
    CHANGED_FILES=""
  fi
  NUM_FILES="$(printf '%s\n' "$CHANGED_FILES" | grep -c . 2>/dev/null || true)"
  NUM_FILES="${NUM_FILES:-0}"

  if ! DIFFSTAT="$(git diff --shortstat "$BASE" "$HEAD_SHA" 2>/dev/null)"; then
    warn "git diff --shortstat failed; lines-changed will be 0"
    DIFFSTAT=""
  fi
  LINES_CHANGED="$(printf '%s\n' "$DIFFSTAT" \
    | grep -oE '[0-9]+ insertion|[0-9]+ deletion' 2>/dev/null \
    | grep -oE '[0-9]+' 2>/dev/null \
    | awk '{s+=$1} END {print s+0}' 2>/dev/null || true)"
  LINES_CHANGED="${LINES_CHANGED:-0}"
fi

[[ "$NUM_FILES" =~ ^[0-9]+$ ]] || NUM_FILES=0
[[ "$LINES_CHANGED" =~ ^[0-9]+$ ]] || LINES_CHANGED=0

has_path() {
  printf '%s\n' "$CHANGED_FILES" | grep -qE "$1" 2>/dev/null || return 1
}

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
  workflow_dispatch)
    SCORE=$((SCORE + 15))
    ;;
  push)
    if [[ "$REF" == "refs/heads/master" || "$REF" == "refs/heads/main" ]]; then
      SCORE=$((SCORE + 25))
    else
      SCORE=$((SCORE + 5))
    fi
    ;;
  pull_request)
    SCORE=$((SCORE - 10))
    ;;
  release)
    SCORE=$((SCORE + 20))
    ;;
  *)
    ;;
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

if [[ "$SCORE" -gt 100 ]]; then SCORE=100; fi
if [[ "$SCORE" -lt 0   ]]; then SCORE=0;   fi

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
  [[ -n "${STRATEGY:-}" ]]     || die "internal: STRATEGY unset"
  [[ -n "${ALLOCATION:-}" ]]   || die "internal: ALLOCATION unset"
  [[ -n "${JOBS:-}" ]]         || die "internal: JOBS unset"
  [[ -n "${MAX_PARALLEL:-}" ]] || die "internal: MAX_PARALLEL unset"

  if [[ $GITHUB_OUTPUT_MODE -eq 1 ]]; then
    if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
      die_env "GITHUB_OUTPUT is not set (are you running inside Actions? use without --github-output for local runs)"
    fi
    if [[ ! -w "$GITHUB_OUTPUT" && ! -w "$(dirname "$GITHUB_OUTPUT")" ]]; then
      die_env "GITHUB_OUTPUT path is not writable: ${GITHUB_OUTPUT}"
    fi
    if ! {
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
    } >> "$GITHUB_OUTPUT"; then
      die_env "failed to write outputs to GITHUB_OUTPUT=${GITHUB_OUTPUT}"
    fi
    log "allocation=${ALLOCATION} jobs=${JOBS} score=${SCORE} warnings=${_WARNINGS}"
    log "reason: ${REASON}"
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
| warnings         $_WARNINGS
| reason           $REASON
+-------------------------------------------------------
EOF
fi

trap - ERR
emit

if [[ $_WARNINGS -gt 0 ]]; then
  log "completed with ${_WARNINGS} warning(s)"
fi

exit 0
