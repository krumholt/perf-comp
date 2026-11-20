#!/bin/sh
# Dump the .NET JIT's machine code for the serial C# loop: once with the loop
# in top-level Main (csharp/) and once with it in its own method (csharp-fn/).
# Usage (from the host):  docker run --rm -v "$PWD/asm:/out" perf-comp ./jit-asm.sh
set -e
OUT=${OUT:-/out}
mkdir -p "$OUT"

DOTNET_JitDisasm='<Main>$' DOTNET_JitStdOutFile="$OUT/csharp-main.asm" \
  dotnet csharp/out/perf.dll
DOTNET_JitDisasm='*Sum*' DOTNET_JitStdOutFile="$OUT/csharp-method.asm" \
  dotnet csharp-fn/out/perf.dll

echo "wrote $OUT/csharp-main.asm and $OUT/csharp-method.asm"
