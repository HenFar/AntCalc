#!/usr/bin/env bash

# Run each requested massive-A30 epsilon depth in a separate Wolfram kernel.
# Results are JSON objects printed by the worker, one per fresh process.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
KERNEL_PATH="${WolframKernel:-/Applications/Wolfram.app/Contents/MacOS/WolframKernel}"
TIMEOUT_SECONDS="${ANTCALC_MX30_BENCHMARK_TIMEOUT:-600}"
ORDERS="${ANTCALC_MX30_BENCHMARK_ORDERS:-0,1,2}"

IFS=',' read -r -a order_list <<< "$ORDERS"
exit_code=0

for order in "${order_list[@]}"; do
  echo "Running fresh-kernel massive A30 benchmark: ExpansionOrder -> $order"
  set +e
  ANTCALC_MX30_BENCHMARK_ORDER="$order" \
  ANTCALC_MX30_BENCHMARK_TIMEOUT="$TIMEOUT_SECONDS" \
    "$KERNEL_PATH" -script "$ROOT/dev/benchmarks/massive_a30/benchmark_massive_a30_epsilon_depth.wl"
  worker_code=$?
  set -e
  if [ "$worker_code" -ne 0 ]; then
    exit_code=$worker_code
  fi
done

exit "$exit_code"
