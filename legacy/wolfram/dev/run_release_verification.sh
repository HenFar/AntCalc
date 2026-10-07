#!/usr/bin/env bash

# Final supported-massless acceptance gate.  Each case is executed in a new
# Wolfram kernel so state contamination is observable rather than hidden.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_PATH="${WolframKernel:-/Applications/Wolfram.app/Contents/MacOS/WolframKernel}"
TIMEOUT_SECONDS="${ANTCALC_RELEASE_TIMEOUT:-7200}"
OUTPUT_DIR="${ANTCALC_RELEASE_OUTPUT_DIR:-$(mktemp -d /tmp/antcalc_release.XXXXXX)}"
KEEP_OUTPUT="${ANTCALC_RELEASE_KEEP_OUTPUT:-0}"

CASES=(
  A20 A21 A30 A31All A22All A22BuildInvariantOnly A22Leading A22Subleading A22Nf A22Breve
  A40Leading A40Subleading B40 C40 A30MassiveBeta
  RRatioLO RRatioNLO RRatioNNLO
)

if [ -n "${ANTCALC_RELEASE_CASES:-}" ]; then
  IFS=',' read -r -a CASES <<< "$ANTCALC_RELEASE_CASES"
fi

mkdir -p "$OUTPUT_DIR"

pass_count=0
fail_count=0
unvalidated_count=0
inconclusive_count=0

run_case() {
  local name="$1"
  local output="$OUTPUT_DIR/$name.json"
  local exit_code

  echo "Running fresh-kernel acceptance case: $name"
  set +e
  ANTCALC_ACCEPTANCE_CASE="$name" \
  ANTCALC_ACCEPTANCE_OUTPUT="$output" \
  ANTCALC_ACCEPTANCE_TIMEOUT="$TIMEOUT_SECONDS" \
  perl -e 'alarm shift @ARGV; exec @ARGV' "$TIMEOUT_SECONDS" \
    "$KERNEL_PATH" -script "$ROOT/dev/release_acceptance_worker.wl"
  exit_code=$?
  set -e

  if [ "$exit_code" -eq 0 ]; then
    echo "$name | status=Validated"
    pass_count=$((pass_count + 1))
  elif [ "$exit_code" -eq 3 ]; then
    echo "$name | status=Unvalidated"
    unvalidated_count=$((unvalidated_count + 1))
  elif [ "$exit_code" -eq 142 ]; then
    echo "$name | status=InconclusiveTimeout"
    inconclusive_count=$((inconclusive_count + 1))
  else
    echo "$name | status=Fail"
    fail_count=$((fail_count + 1))
  fi
}

for case_name in "${CASES[@]}"; do
  run_case "$case_name"
done

echo
echo "=== RELEASE ACCEPTANCE SUMMARY ==="
echo "NumValidated=$pass_count"
echo "NumFailed=$fail_count"
echo "NumUnvalidated=$unvalidated_count"
echo "NumInconclusiveTimeout=$inconclusive_count"
echo "Machine-readable case reports: $OUTPUT_DIR"
echo "Scope: supported massless routes plus the beta massive-A30 closure."

if [ "$KEEP_OUTPUT" -ne 1 ] && [ "$fail_count" -eq 0 ] && [ "$unvalidated_count" -eq 0 ] && [ "$inconclusive_count" -eq 0 ]; then
  echo "Set ANTCALC_RELEASE_KEEP_OUTPUT=1 to retain the per-case JSON evidence."
fi

if [ "$fail_count" -gt 0 ] || [ "$unvalidated_count" -gt 0 ]; then
  exit 1
fi

if [ "$inconclusive_count" -gt 0 ]; then
  exit 2
fi

exit 0
