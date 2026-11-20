#!/bin/sh
# Runs every benchmark RUNS times, then prints a comparison table.
set -e
RUNS=${RUNS:-3}
RESULTS=$(mktemp)

# Pull the "<n> ms" timing out of a program's output line.
ms() { sed -n 's/.*Sum Time:\{0,1\} \([0-9][0-9]*\) ms.*/\1/p' | head -n1; }
# Pull the sum value out of a program's output line.
val() { sed -n 's/.*Sum: \([^ ,]*\).*/\1/p' | head -n1; }

# record <language> <mode> <variant> <program output line>
record() { printf '%s|%s|%s|%s|%s\n' "$1" "$2" "$3" "$(echo "$4" | ms)" "$(echo "$4" | val)" >> "$RESULTS"; }

echo "dotnet $(dotnet --version) | $(rustc --version | cut -d' ' -f1-2) | $(sbcl --version) | $(nproc) CPUs"
echo

for i in $(seq 1 "$RUNS"); do
  printf 'Run %d/%d ... ' "$i" "$RUNS"

  record "C#"   serial   "for loop"            "$(dotnet csharp/out/perf.dll)"
  record "C#"   serial   "for loop in method"  "$(dotnet csharp-fn/out/perf.dll)"
  out=$(dotnet csharp-parallel/out/perf.dll)
  record "C#"   parallel "PLINQ"               "$(echo "$out" | grep PLINQ)"
  record "C#"   parallel "Parallel.ForEach"    "$(echo "$out" | grep Partitioner)"

  record "Rust" serial   "iter().sum()"        "$(./rust/target/release/serial)"
  record "Rust" parallel "rayon"               "$(./rust/target/release/perf)"

  out=$(./sbcl/sum)
  record "SBCL" serial   "loop"                "$(echo "$out" | grep Serial)"
  record "SBCL" parallel "sb-thread x$(nproc)" "$(echo "$out" | grep Parallel)"
  lp=$(./sbcl/sum-lparallel)
  record "SBCL" parallel "lparallel pmap-reduce" "$(echo "$lp" | grep ^Plain)"

  # Optimized: same algorithm in all three (8 accumulators, 256 chunks)
  out=$(dotnet csharp-opt/out/perf.dll)
  record "C#"   serial-8acc   "8 accumulators"      "$(echo "$out" | grep Serial)"
  record "C#"   parallel-8acc "PLINQ 256 chunks"    "$(echo "$out" | grep Parallel)"
  out=$(./rust/target/release/opt)
  record "Rust" serial-8acc   "8 accumulators"      "$(echo "$out" | grep Serial)"
  record "Rust" parallel-8acc "rayon 256 chunks"    "$(echo "$out" | grep Parallel)"
  out=$(./sbcl/sum-opt)
  record "SBCL" serial-8acc   "8 accumulators"      "$(echo "$out" | grep Serial)"
  record "SBCL" parallel-8acc "sb-thread 256 chunks" "$(echo "$out" | grep Parallel)"
  record "SBCL" parallel-8acc "lparallel 256 chunks" "$(echo "$lp" | grep ^8acc)"

  # Explicit AVX SIMD: 4 x f64x4 accumulators in all three
  out=$(dotnet csharp-simd/out/perf.dll)
  record "C#"   serial-simd   "Vector256"           "$(echo "$out" | grep Serial)"
  record "C#"   parallel-simd "Vector256 + PLINQ"   "$(echo "$out" | grep Parallel)"
  out=$(./rust/target/release/simd)
  record "Rust" serial-simd   "std::arch AVX"       "$(echo "$out" | grep Serial)"
  record "Rust" parallel-simd "std::arch + rayon"   "$(echo "$out" | grep Parallel)"
  out=$(./sbcl/sum-simd)
  record "SBCL" serial-simd   "sb-simd f64.4"       "$(echo "$out" | grep Serial)"
  record "SBCL" parallel-simd "sb-simd + sb-thread" "$(echo "$out" | grep Parallel)"
  record "SBCL" parallel-simd "sb-simd + lparallel" "$(echo "$lp" | grep ^Simd)"

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
