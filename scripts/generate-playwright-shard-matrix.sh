#!/usr/bin/env bash
# generate-playwright-shard-matrix.sh
#
# Dynamically compute a GitHub Actions matrix for Playwright (or any
# Playwright-compatible) test sharding.
#
# The script counts tests (via `npx playwright test --list`), decides how many
# shards to create based on configurable density, clamps to min/max bounds,
# validates the resulting JSON, and optionally writes it to $GITHUB_OUTPUT.
#
# Usage (local):
#   ./scripts/generate-playwright-shard-matrix.sh [OPTIONS]
#
# Usage (Actions – recommended):
#   - name: Generate shard matrix
#     id: shards
#     run: bash scripts/generate-playwright-shard-matrix.sh --github-output
#
# Options:
#   --tests-per-shard N   Target tests per shard (default: 25)
#   --min-shards N        Minimum shards (default: 1)
#   --max-shards N        Maximum shards (default: 12)
#   --project NAME        Limit to a Playwright project (optional)
#   --grep PATTERN        Pass --grep to the list command (optional)
#   --list-cmd CMD        Override the full list command
#   --fallback-count N    If listing fails, use this test count (default: 40)
#   --github-output       Write matrix + metadata to $GITHUB_OUTPUT
#   --pretty              Pretty-print human summary + JSON
#   -h, --help            Show help
#
# Environment overrides:
#   PW_TESTS_PER_SHARD, PW_MIN_SHARDS, PW_MAX_SHARDS, PW_PROJECT, PW_GREP
#
# Exit codes:
#   0  success (always emits a usable matrix; soft failures fall back)
#   1  invalid arguments
#   2  missing dependency (jq / node)

set -euo pipefail

SCRIPT_NAME="generate-playwright-shard-matrix.sh"
TESTS_PER_SHARD="${PW_TESTS_PER_SHARD:-25}"
MIN_SHARDS="${PW_MIN_SHARDS:-1}"
MAX_SHARDS="${PW_MAX_SHARDS:-12}"
PROJECT="${PW_PROJECT:-}"
GREP="${PW_GREP:-}"
LIST_CMD=""
FALLBACK_COUNT=40
GITHUB_OUTPUT_MODE=0
PRETTY=0

log()  { printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2; }
warn() { log "WARNING: $*"; }
die()  { log "ERROR: $*"; exit 1; }
die_dep() { log "ERROR: $*"; exit 2; }

usage() {
  sed -n '2,45p' "$0" | sed 's/^# \?//'
  exit 0
}

need_arg() {
  local opt="$1" val="${2:-}"
  if [[ -z "$val" || "$val" == --* ]]; then
    die "option ${opt} requires a value"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tests-per-shard) need_arg "$1" "${2:-}"; TESTS_PER_SHARD="$2"; shift 2 ;;
    --min-shards)      need_arg "$1" "${2:-}"; MIN_SHARDS="$2"; shift 2 ;;
    --max-shards)      need_arg "$1" "${2:-}"; MAX_SHARDS="$2"; shift 2 ;;
    --project)         need_arg "$1" "${2:-}"; PROJECT="$2"; shift 2 ;;
    --grep)            need_arg "$1" "${2:-}"; GREP="$2"; shift 2 ;;
    --list-cmd)        need_arg "$1" "${2:-}"; LIST_CMD="$2"; shift 2 ;;
    --fallback-count)  need_arg "$1" "${2:-}"; FALLBACK_COUNT="$2"; shift 2 ;;
    --github-output)   GITHUB_OUTPUT_MODE=1; shift ;;
    --pretty)          PRETTY=1; shift ;;
    -h|--help)         usage ;;
    *)                 die "unknown option: $1" ;;
  esac
done

# Validate numeric bounds
[[ "$TESTS_PER_SHARD" =~ ^[1-9][0-9]*$ ]] || die "tests-per-shard must be a positive integer"
[[ "$MIN_SHARDS" =~ ^[1-9][0-9]*$ ]]      || die "min-shards must be a positive integer"
[[ "$MAX_SHARDS" =~ ^[1-9][0-9]*$ ]]      || die "max-shards must be a positive integer"
[[ "$FALLBACK_COUNT" =~ ^[0-9]+$ ]]       || die "fallback-count must be a non-negative integer"
(( MAX_SHARDS >= MIN_SHARDS ))            || die "max-shards must be >= min-shards"

command -v jq >/dev/null 2>&1 || die_dep "jq is required (apt-get install jq / brew install jq)"

# ---------------------------------------------------------------------------
# Count tests
# ---------------------------------------------------------------------------
count_tests() {
  local cmd
  if [[ -n "$LIST_CMD" ]]; then
    cmd="$LIST_CMD"
  else
    cmd="npx --yes playwright test --list --reporter=json"
    [[ -n "$PROJECT" ]] && cmd+=" --project=${PROJECT}"
    [[ -n "$GREP" ]]    && cmd+=" --grep=${GREP}"
  fi

  local raw count=0
  # Capture both stdout and stderr; Playwright list can be noisy
  if raw=$(eval "$cmd" 2>/dev/null); then
    # Try structured JSON first (Playwright ≥1.40 style)
    count=$(echo "$raw" | jq -r '
      ( .suites // [] )
      | map( .. | objects | select(has("specs")) | .specs | length )
      | add // 0
    ' 2>/dev/null || echo 0)

    # Fallback: count "spec" lines / test titles if JSON parse failed
    if [[ "$count" -eq 0 ]]; then
      count=$(echo "$raw" | grep -cE '^\s*(✓|✘|○|\[.*\].*\.spec\.|test\()' || true)
    fi
  fi

  # Final safety
  if [[ -z "$count" || "$count" -eq 0 ]]; then
    warn "could not determine test count (list command may have failed); using fallback=${FALLBACK_COUNT}"
    count=$FALLBACK_COUNT
  fi
  echo "$count"
}

TEST_COUNT=$(count_tests)
log "detected ${TEST_COUNT} test(s)"

# ---------------------------------------------------------------------------
# Compute shard count
# ---------------------------------------------------------------------------
# Ceiling division: (n + d - 1) / d
SHARD_COUNT=$(( (TEST_COUNT + TESTS_PER_SHARD - 1) / TESTS_PER_SHARD ))
(( SHARD_COUNT < MIN_SHARDS )) && SHARD_COUNT=$MIN_SHARDS
(( SHARD_COUNT > MAX_SHARDS )) && SHARD_COUNT=$MAX_SHARDS
# Edge case: zero tests still produces one empty-ish shard
(( SHARD_COUNT < 1 )) && SHARD_COUNT=1

log "shards=${SHARD_COUNT} (target ${TESTS_PER_SHARD} tests/shard, clamp ${MIN_SHARDS}..${MAX_SHARDS})"

# ---------------------------------------------------------------------------
# Build & validate matrix JSON
# ---------------------------------------------------------------------------
# Produce an "include" array of {shardIndex, shardTotal} objects.
# GitHub Actions strategy.matrix.include consumes this directly.
MATRIX_JSON=$(jq -cn --argjson count "$SHARD_COUNT" '
  {
    include: [
      range(1; $count + 1)
      | { shardIndex: ., shardTotal: $count }
    ]
  }
')

# Validate shape
if ! echo "$MATRIX_JSON" | jq -e '
  type == "object"
  and has("include")
  and (.include | type == "array")
  and (.include | length > 0)
  and all(.include[]; has("shardIndex") and has("shardTotal"))
' >/dev/null; then
  die "generated matrix failed validation"
fi

# Compact form for GITHUB_OUTPUT
MATRIX_COMPACT=$(echo "$MATRIX_JSON" | jq -c .)

if [[ $PRETTY -eq 1 ]]; then
  echo "tests=${TEST_COUNT}  shards=${SHARD_COUNT}  tests-per-shard≈$(( TEST_COUNT / SHARD_COUNT ))"
  echo "$MATRIX_JSON" | jq .
fi

if [[ $GITHUB_OUTPUT_MODE -eq 1 ]]; then
  [[ -n "${GITHUB_OUTPUT:-}" ]] || die "GITHUB_OUTPUT is not set (run inside GitHub Actions or export it)"
  {
    echo "matrix<<EOF"
    echo "$MATRIX_COMPACT"
    echo "EOF"
    echo "shard-count=${SHARD_COUNT}"
    echo "test-count=${TEST_COUNT}"
  } >> "$GITHUB_OUTPUT"
  log "wrote matrix (${SHARD_COUNT} shards, ${TEST_COUNT} tests) to GITHUB_OUTPUT"
else
  # Default: emit compact JSON on stdout for capture by callers
  echo "$MATRIX_COMPACT"
fi
