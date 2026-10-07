#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ANTENNA_PIPELINE_ROOT="$ROOT"
KERNEL_PATH="${WolframKernel:-/Applications/Wolfram.app/Contents/MacOS/WolframKernel}"

if ! command -v wolframscript >/dev/null 2>&1; then
  echo "wolframscript was not found on PATH."
  exit 1
fi

WolframKernel="$KERNEL_PATH" wolframscript -file "$ROOT/dev/run_physics_validation.wl"
