#!/bin/sh
# Dump C2's machine code for Variants.loop: the on-stack-replacement version
# (what a loop called once runs) and the normally compiled version.
# Needs hsdis (libhsdis0-fcml, in the image); its output is raw bytes, so they
# are decoded with objdump.
# Usage (from the host):  docker run --rm -v "$PWD/asm:/out" perf-comp ./java-asm.sh
set -e
OUT=${OUT:-/out}
mkdir -p "$OUT"
T=$(mktemp -d)

# extract <PrintAssembly log> osr|normal > hex   (first C2 method of that kind)
extract() {
  awk -v want="$2" '
    /^Compiled method/ { if (done) exit
                         grab = /\(c2\)/ && ((want == "osr") == / % /); next }
    grab && /\[\/MachCode\]/ { done = 1; grab = 0 }
    grab && /^ +0x[0-9a-f]+: [0-9a-f| ]+$/ { sub(/^ +0x[0-9a-f]+: /, ""); gsub(/[| ]/, ""); printf "%s", $0 }
  ' "$1"
}
decode() { perl -ne 'print pack("H*", $_)' > "$T/bin"
           objdump -D -b binary -mi386:x86-64 -Mintel "$T/bin" | sed '1,/<.data>:/d'; }

P="-XX:+UnlockDiagnosticVMOptions -XX:CompileCommand=quiet -XX:CompileCommand=print,Variants::loop"
java -cp java/out $P Variants loop      > "$T/osr.log"
java -cp java/out $P Variants loop-warm > "$T/warm.log"
{ echo "; C2 OSR compilation of Variants.loop (Variants loop)"; extract "$T/osr.log" osr | decode; } > "$OUT/java-loop-osr.asm"
{ echo "; C2 normal compilation of Variants.loop (Variants loop-warm)"; extract "$T/warm.log" normal | decode; } > "$OUT/java-loop-method.asm"
rm -rf "$T"
echo "wrote $OUT/java-loop-osr.asm and $OUT/java-loop-method.asm"
