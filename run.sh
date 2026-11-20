#!/bin/sh
# Runs every benchmark RUNS times, then prints a comparison table.
#
# Measurement setup (so the table shows the code, not the CPU's power
# management):
#   serial entries   - the program is pinned to the fastest core (taskset),
#                      after a 100 ms busy-wait on that core so its clock has
#                      ramped up
#   parallel entries - a separate run, after a 100 ms busy-wait on all cores
# Programs that print both a serial and a parallel result are run twice and
# each line is taken from the run set up for it.
set -e
RUNS=${RUNS:-3}
WARMUP=${WARMUP:-0.1}
RESULTS=$(mktemp)

# Fastest core by max frequency (falls back to CPU 0 if cpufreq is missing)
FAST=$(for f in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq; do
         [ -r "$f" ] && echo "$(cat "$f") $(echo "$f" | sed 's|.*/cpu\([0-9]*\)/.*|\1|')"
       done | sort -n -k1,1 -k2,2r | tail -n1 | cut -d' ' -f2)
FAST=${FAST:-0}

spin() {   # busy-wait on CPU $1 for $WARMUP seconds (0 = no warm-up)
  case "$WARMUP" in 0|0.0|"") return 0 ;; esac
  taskset -c "$1" timeout "$WARMUP" sh -c 'while :; do :; done' || true
}
spin_all() { c=0; while [ "$c" -lt "$(nproc)" ]; do spin "$c" & c=$((c+1)); done; wait; }
serial()   { spin "$FAST"; taskset -c "$FAST" "$@"; }
parallel() { spin_all; "$@"; }

# Pull the "<n> ms" timing out of a program's output line.
ms() { sed -n 's/.*Sum Time:\{0,1\} \([0-9][0-9]*\) ms.*/\1/p' | head -n1; }
# Pull the sum value out of a program's output line.
val() { sed -n 's/.*Sum: \([^ ,]*\).*/\1/p' | head -n1; }

# record <language> <mode> <variant> <program output line>
record() { printf '%s|%s|%s|%s|%s\n' "$1" "$2" "$3" "$(echo "$4" | ms)" "$(echo "$4" | val)" >> "$RESULTS"; }

echo "dotnet $(dotnet --version) | $(rustc --version | cut -d' ' -f1-2) | $(sbcl --version) | $(nproc) CPUs"
echo "serial runs pinned to CPU $FAST; ${WARMUP}s warm-up before every run"
echo

for i in $(seq 1 "$RUNS"); do
  printf 'Run %d/%d ... ' "$i" "$RUNS"

  # Original programs
  record "C#"   serial   "for loop"              "$(serial dotnet csharp/out/perf.dll)"
  record "C#"   serial   "for loop in method"    "$(serial dotnet csharp-fn/out/perf.dll)"
  out=$(parallel dotnet csharp-parallel/out/perf.dll)
  record "C#"   parallel "PLINQ"                 "$(echo "$out" | grep PLINQ)"
  record "C#"   parallel "Parallel.ForEach"      "$(echo "$out" | grep Partitioner)"

  record "Rust" serial   "iter().sum()"          "$(serial ./rust/target/release/serial)"
  record "Rust" parallel "rayon"                 "$(parallel ./rust/target/release/perf)"

  record "SBCL" serial   "loop"                  "$(serial ./sbcl/sum | grep Serial)"
  record "SBCL" parallel "sb-thread x$(nproc)"   "$(parallel ./sbcl/sum | grep Parallel)"
  lp=$(parallel ./sbcl/sum-lparallel)
  record "SBCL" parallel "lparallel pmap-reduce" "$(echo "$lp" | grep ^Plain)"

  # Optimized: same algorithm in all three (8 accumulators, 256 chunks)
  record "C#"   serial-8acc   "8 accumulators"       "$(serial dotnet csharp-opt/out/perf.dll | grep Serial)"
  record "C#"   parallel-8acc "PLINQ 256 chunks"     "$(parallel dotnet csharp-opt/out/perf.dll | grep Parallel)"
  record "Rust" serial-8acc   "8 accumulators"       "$(serial ./rust/target/release/opt | grep Serial)"
  record "Rust" parallel-8acc "rayon 256 chunks"     "$(parallel ./rust/target/release/opt | grep Parallel)"
  record "SBCL" serial-8acc   "8 accumulators"       "$(serial ./sbcl/sum-opt | grep Serial)"
  record "SBCL" parallel-8acc "sb-thread 256 chunks" "$(parallel ./sbcl/sum-opt | grep Parallel)"
  record "SBCL" parallel-8acc "lparallel 256 chunks" "$(echo "$lp" | grep ^8acc)"

  # Explicit AVX SIMD: 4 x f64x4 accumulators in all three
  record "C#"   serial-simd   "Vector256"            "$(serial dotnet csharp-simd/out/perf.dll | grep Serial)"
  record "C#"   parallel-simd "Vector256 + PLINQ"    "$(parallel dotnet csharp-simd/out/perf.dll | grep Parallel)"
  record "Rust" serial-simd   "std::arch AVX"        "$(serial ./rust/target/release/simd | grep Serial)"
  record "Rust" parallel-simd "std::arch + rayon"    "$(parallel ./rust/target/release/simd | grep Parallel)"
  record "SBCL" serial-simd   "sb-simd f64.4"        "$(serial ./sbcl/sum-simd | grep Serial)"
  record "SBCL" parallel-simd "sb-simd + sb-thread"  "$(parallel ./sbcl/sum-simd | grep Parallel)"
  record "SBCL" parallel-simd "sb-simd + lparallel"  "$(echo "$lp" | grep ^Simd)"

  echo done
done
echo

awk -F'|' -v runs="$RUNS" '
  {
    key = $2 "|" $1 "|" $3
    if (!(key in total)) { order[++n] = key; sum[key] = $5 }
    t[key, ++cnt[key]] = $4
    total[key] += $4
  }
  END {
    # fastest average per mode, for the relative column
    for (k = 1; k <= n; k++) {
      key = order[k]; split(key, p, "|"); avg[key] = total[key] / runs
      if (!(p[1] in best) || avg[key] < best[p[1]]) best[p[1]] = avg[key]
    }
    line = "+---------------+--------+------------------------+"
    for (r = 1; r <= runs; r++) line = line "--------+"
    line = line "---------+---------+---------+"
    hdr = sprintf("| %-13s | %-6s | %-22s |", "Mode", "Lang", "Variant")
    for (r = 1; r <= runs; r++) hdr = hdr sprintf(" %6s |", "Run " r)
    hdr = hdr sprintf(" %7s | %7s | %7s |", "Total", "Avg", "vs best")

    print line; print hdr
    split("serial parallel serial-8acc parallel-8acc serial-simd parallel-simd", modes, " ")
    for (m = 1; m <= 6; m++) {
      print line
      # sort rows of this mode by average (simple selection sort)
      c = 0
      for (k = 1; k <= n; k++) { split(order[k], p, "|"); if (p[1] == modes[m]) rows[++c] = order[k] }
      for (a = 1; a <= c; a++) for (b = a + 1; b <= c; b++)
        if (avg[rows[b]] < avg[rows[a]]) { tmp = rows[a]; rows[a] = rows[b]; rows[b] = tmp }
      for (a = 1; a <= c; a++) {
        key = rows[a]; split(key, p, "|")
        row = sprintf("| %-13s | %-6s | %-22s |", p[1], p[2], p[3])
        for (r = 1; r <= runs; r++) row = row sprintf(" %6d |", t[key, r])
        row = row sprintf(" %7d | %7.0f | %6.1fx |", total[key], avg[key], avg[key] / best[p[1]])
        print row
      }
    }
    print line
    print "Times in ms. \"vs best\" = average relative to the fastest in the same mode."
    print ""
    print "Sum results (exact answer is 500000000500000000):"
    for (k = 1; k <= n; k++) { split(order[k], p, "|"); printf "  %-5s %-13s %-22s %s\n", p[2], p[1], p[3], sum[order[k]] }
  }
' "$RESULTS"

rm -f "$RESULTS"
