#!/bin/zsh

KERNEL="/Applications/Wolfram.app/Contents/MacOS/WolframKernel"

if [ ! -x "$KERNEL" ]; then
  echo "WolframKernel not found at: $KERNEL" >&2
  exit 1
fi

"$KERNEL" -noprompt "$@"
