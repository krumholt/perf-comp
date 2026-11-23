#!/bin/sh
# Takes the Java parallel-stream program apart (see README, "Why the Java
# version is slow"). Serial runs are pinned to the fastest core like run.sh.
# Usage (from the host):  docker run --rm perf-comp ./java-experiments.sh
FAST=$(for f in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq; do
         [ -r "$f" ] && echo "$(cat "$f") $(echo "$f" | sed 's|.*/cpu\([0-9]*\)/.*|\1|')"
       done | sort -n -k1,1 -k2,2r | tail -n1 | cut -d' ' -f2)
FAST=${FAST:-0}
J="java -cp java/out"

echo "== 1. DoubleStream.sum() vs reduce(Double::sum), 5 reps in one JVM (rep 1 = cold)"
$J Variants par-sum 5
$J Variants par-reduce 5

echo; echo "== 2. Same, serial (pinned to CPU $FAST), and the arithmetic alone in a warm loop"
taskset -c "$FAST" $J Variants seq-sum
taskset -c "$FAST" $J Variants seq-reduce
taskset -c "$FAST" $J Variants kahan-warm
taskset -c "$FAST" $J Variants loop-warm

echo; echo "== 3. JIT tiers, cold run (rep 1) and warm run (rep 2)"
for o in "" "-XX:-TieredCompilation" "-XX:TieredStopAtLevel=1"; do
  echo "-- flags: ${o:-(default tiered)}"
  $J $o Variants par-reduce 2
  $J $o Variants par-sum 2
done

echo; echo "== 4. When the stream's inner loop gets C2 code (ms since JVM start; % = OSR)"
$J -XX:+PrintCompilation Variants par-reduce | grep -E 'RangeIntSpliterator::forEachRemaining|Sum Time'

echo; echo "== 5. Plain for loop: on-stack-replaced (cold) vs normally compiled (warm)"
taskset -c "$FAST" $J Variants loop
taskset -c "$FAST" $J Variants loop-warm

echo; echo "== 6. AOT cache (JDK 25, trained on the same program): when C2 code arrives now"
java -XX:AOTMode=on -XX:AOTCache=java/sumint-reduce.aot -XX:+PrintCompilation -cp java/sum.jar SumIntReduce \
  | grep -E 'RangeIntSpliterator::forEachRemaining|Sum Time'

echo; echo "== 7. native-image: 1 thread vs all cores of one type (how it scales on each core type)"
P=-Djava.util.concurrent.ForkJoinPool.common.parallelism
for spec in "P-core:2:0" "4 P-cores:0-3:3" "E-core:4:0" "8 E-cores:4-11:7" "all 16:0-15:15"; do
  IFS=: read -r name cpus n <<SPEC
$spec
SPEC
  out=$(taskset -c "$cpus" ./java/sumint-reduce-native "$P=$n" | grep 'Sum Time')
  printf '%-10s %s\n' "$name" "$out"
done
