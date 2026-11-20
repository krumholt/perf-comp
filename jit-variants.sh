#!/bin/sh
# Runs the four jit-variants programs under default (tiered) and FullOpts JIT
# settings, and counts stack loads/stores right after the loop's vaddsd.
# Usage (from the host):  docker run --rm perf-comp ./jit-variants.sh
for d in jit-variants/*/; do
  n=$(basename "$d")
  for cfg in "tiered:" "FullOpts:DOTNET_TieredCompilation=0"; do
    rm -f /tmp/j.txt
    out=$(env ${cfg#*:} DOTNET_JitDisasm='<Main>$ *Sum*' DOTNET_JitStdOutFile=/tmp/j.txt \
          dotnet "$d/out/perf.dll" | tr '\n' ' ')
    spills=$(awk '/Assembly listing/{p=0} /Tier1|FullOpts/{p=1} p' /tmp/j.txt \
             | grep -A8 vaddsd | head -9 | grep -c 'vmovsd .*ptr \[rbp')
    printf '%-28s %-9s %-36s stack ops in loop: %s\n' "$n" "${cfg%%:*}" "$out" "$spills"
  done
done
