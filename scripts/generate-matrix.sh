#!/usr/bin/env bash
# generate-matrix.sh – Produce a validated GitHub Actions matrix JSON
# suitable for strategy.matrix: ${{ fromJson(...) }}
#
# Usage:
#   ./scripts/generate-matrix.sh [OPTIONS]
#
# Options:
#   --allocation LEVEL   high-performance | balanced | standard | minimal
#                        (default: balanced)
#   --focus AREA         nnue | search | general  (default: general)
#   --event NAME         push | pull_request | schedule | workflow_dispatch
#                        (default: push)
#   --stages NAME        Override stages label (parallel | sequential | minimal)
#   --github-output      Write matrix + stages to $GITHUB_OUTPUT with proper
#                        multiline delimiter (required for CI)
#   --pretty             Pretty-print JSON to stdout (human inspection)
#   --validate-only      Only validate an existing JSON file (pass path as arg)
#   -h, --help           Show this help
#
# Environment (used when options are omitted):
#   MATRIX_ALLOCATION, MATRIX_FOCUS, GITHUB_EVENT_NAME
#
# Exit codes:
#   0  success
#   1  invalid arguments / validation failure
#   2  missing dependency (jq)

set -euo pipefail

ALLOCATION="${MATRIX_ALLOCATION:-balanced}"
FOCUS="${MATRIX_FOCUS:-general}"
EVENT="${GITHUB_EVENT_NAME:-push}"
STAGES_OVERRIDE=""
GITHUB_OUTPUT_MODE=0
PRETTY=0
VALIDATE_ONLY=""

die()  { echo "generate-matrix.sh: $*" >&2; exit 1; }
need_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "generate-matrix.sh: jq is required (apt-get install jq / brew install jq)" >&2
    exit 2
  fi
}

usage() {
  sed -n '2,30p' "$0" | sed 's/^# \?//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allocation)   ALLOCATION="$2"; shift 2 ;;
    --focus)        FOCUS="$2"; shift 2 ;;
    --event)        EVENT="$2"; shift 2 ;;
    --stages)       STAGES_OVERRIDE="$2"; shift 2 ;;
    --github-output) GITHUB_OUTPUT_MODE=1; shift ;;
    --pretty)       PRETTY=1; shift ;;
    --validate-only) VALIDATE_ONLY="$2"; shift 2 ;;
    -h|--help)      usage ;;
    *)              die "unknown option: $1" ;;
  esac
done

need_jq

# ---------------------------------------------------------------------------
# Validation helper
# ---------------------------------------------------------------------------
validate_matrix() {
  local json="$1"
  # Must be an object with an "include" array
  if ! echo "$json" | jq -e 'type == "object" and has("include") and (.include | type == "array")' >/dev/null; then
    die "matrix must be an object with an \"include\" array"
  fi
  # Every entry must be an object containing at least os + arch
  local bad
  bad=$(echo "$json" | jq -r '
    .include[]
    | select((type != "object") or (has("os") | not) or (has("arch") | not))
    | "missing os/arch in entry: \(.)"
  ')
  if [[ -n "$bad" ]]; then
    die "$bad"
  fi
  # Optional but recommended: priority must be high|medium|low when present
  bad=$(echo "$json" | jq -r '
    .include[]
    | select(has("priority") and (.priority | IN("high","medium","low") | not))
    | "invalid priority in entry: \(.)"
  ')
  if [[ -n "$bad" ]]; then
    die "$bad"
  fi
  return 0
}

if [[ -n "$VALIDATE_ONLY" ]]; then
  [[ -f "$VALIDATE_ONLY" ]] || die "file not found: $VALIDATE_ONLY"
  validate_matrix "$(cat "$VALIDATE_ONLY")"
  echo "OK: $VALIDATE_ONLY is a valid matrix"
  exit 0
fi

# ---------------------------------------------------------------------------
# Matrix definitions (keep in sync with project needs)
# ---------------------------------------------------------------------------
# high-performance → full coverage, parallel stages
# balanced         → main platforms only
# standard / minimal → single cheap job (PR / conservative)

build_matrix() {
  local alloc="$1"
  case "$alloc" in
    high-performance|high-cpu)
      cat <<'EOF'
{
  "include": [
    {"os": "ubuntu-latest",  "arch": "x86-64-avx2", "priority": "high"},
    {"os": "ubuntu-latest",  "arch": "x86-64-bmi2", "priority": "high"},
    {"os": "macos-latest",   "arch": "x86-64-avx2", "priority": "medium"},
    {"os": "windows-latest", "arch": "x86-64-avx2", "priority": "medium"},
    {"os": "ubuntu-latest",  "arch": "armv8",       "priority": "low"}
  ]
}
EOF
      ;;
    balanced)
      cat <<'EOF'
{
  "include": [
    {"os": "ubuntu-latest",  "arch": "x86-64-avx2", "priority": "high"},
    {"os": "macos-latest",   "arch": "x86-64-avx2", "priority": "medium"},
    {"os": "windows-latest", "arch": "x86-64-avx2", "priority": "medium"}
  ]
}
EOF
      ;;
    standard)
      # Slightly leaner than balanced – useful for PRs
      cat <<'EOF'
{
  "include": [
    {"os": "ubuntu-latest", "arch": "x86-64-avx2", "priority": "high"},
    {"os": "ubuntu-latest", "arch": "x86-64",      "priority": "medium"}
  ]
}
EOF
      ;;
    minimal|*)
      cat <<'EOF'
{
  "include": [
    {"os": "ubuntu-latest", "arch": "x86-64", "priority": "high"}
  ]
}
EOF
      ;;
  esac
}

# Optional focus-based filtering / enrichment
apply_focus() {
  local json="$1"
  local focus="$2"
  case "$focus" in
    nnue)
      # Prefer architectures that exercise NNUE heavily; keep the same shape
      echo "$json" | jq '
        .include |= map(
          if .arch == "x86-64-avx2" then . + {"nnue": true} else . end
        )
      '
      ;;
    search)
      echo "$json" | jq '
        .include |= map(. + {"search_focus": true})
      '
      ;;
    *)
      echo "$json"
      ;;
  esac
}

derive_stages() {
  local alloc="$1"
  if [[ -n "$STAGES_OVERRIDE" ]]; then
    echo "$STAGES_OVERRIDE"
    return
  fi
  case "$alloc" in
    high-performance|high-cpu) echo "parallel"   ;;
    balanced)                  echo "sequential" ;;
    *)                         echo "minimal"    ;;
  esac
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
MATRIX_JSON=$(build_matrix "$ALLOCATION")
MATRIX_JSON=$(apply_focus "$MATRIX_JSON" "$FOCUS")
# Compact + canonicalise
MATRIX_JSON=$(echo "$MATRIX_JSON" | jq -c .)

validate_matrix "$MATRIX_JSON"

STAGES=$(derive_stages "$ALLOCATION")
COUNT=$(echo "$MATRIX_JSON" | jq '.include | length')

if [[ $PRETTY -eq 1 ]]; then
  echo "allocation=$ALLOCATION  focus=$FOCUS  event=$EVENT  stages=$STAGES  jobs=$COUNT"
  echo "$MATRIX_JSON" | jq .
fi

if [[ $GITHUB_OUTPUT_MODE -eq 1 ]]; then
  [[ -n "${GITHUB_OUTPUT:-}" ]] || die "GITHUB_OUTPUT is not set (are you running inside Actions?)"
  {
    echo "matrix<<EOF"
    echo "$MATRIX_JSON"
    echo "EOF"
    echo "stages=$STAGES"
    echo "job-count=$COUNT"
  } >> "$GITHUB_OUTPUT"
  echo "generate-matrix.sh: wrote matrix ($COUNT jobs, stages=$STAGES) to GITHUB_OUTPUT" >&2
else
  # Default: emit compact JSON on stdout so callers can capture it
  echo "$MATRIX_JSON"
fi
