# perf-comp: C# vs Rust vs SBCL

Sum the integers 1..1,000,000,000 as double-precision floats, in C#, Rust and
SBCL (Common Lisp), going from a plain loop to explicit SIMD, single-threaded
and parallel.

Everything builds and runs in one Docker image:

```sh
docker build -t perf-comp .
docker run --rm perf-comp              # 3 runs of everything + comparison table
docker run --rm -e RUNS=5 perf-comp    # more runs
```

For the shortest idiomatic version in each language, and what it costs, see
[beauty-competition.md](beauty-competition.md).

## Toolchain and machine

| | |
|---|---|
| C# | .NET 9.0 SDK, Release build, default tiered JIT |
| Rust | rustc 1.100 stable, `--release` (no `target-cpu=native`) |
| SBCL | 2.6.10 (official binary), `(optimize (speed 3) (safety 0))`, saved as an executable; lparallel 2.8.4 via Quicklisp |
| Base image | `mcr.microsoft.com/dotnet/sdk:9.0-noble` (Ubuntu 24.04; SBCL 2.6.10 needs glibc ≥ 2.38) |
| CPU | Intel Core Ultra X7 358H, AVX2 (no AVX-512), 16 cores: 4 P-cores @ 4.7 GHz, 8 E-cores @ 3.7 GHz, 4 low-power E-cores @ 3.3 GHz |

## Results

Times in ms (average of 3 runs, on AC power); "vs best" compares each average
to the fastest entry in the same group. See [How it is measured](#how-it-is-measured).

| Group | Lang | Variant | Avg (ms) | vs best |
|---|---|---|---:|---:|
| **serial** | Rust | `iter().sum()` | 466 | 1.0x |
| | C# | for loop in its own method | 479 | 1.0x |
| | SBCL | `loop` | 558 | 1.2x |
| | C# | for loop in top-level `Main` (original) | 2144 | 4.6x |
| **parallel** | Rust | rayon | 37 | 1.0x |
| | SBCL | lparallel `pmap-reduce`, 256 chunks | 40 | 1.1x |
| | C# | `Parallel.ForEach` + range partitioner | 43 | 1.2x |
| | SBCL | `sb-thread` × 16, equal split | 70 | 1.9x |
| | C# | PLINQ (per element) | 283 | 7.6x |
| **serial-8acc** | Rust | 8 accumulators | 173 | 1.0x |
| | C# | 8 accumulators | 249 | 1.4x |
| | SBCL | 8 accumulators | 249 | 1.4x |
| **parallel-8acc** | Rust | rayon, 256 chunks | 11 | 1.0x |
| | SBCL | `sb-thread`, 256 chunks | 17 | 1.6x |
| | SBCL | lparallel `pmap-reduce`, 256 chunks | 17 | 1.6x |
| | C# | PLINQ, 256 chunks | 25 | 2.3x |
| **serial-simd** | Rust | `std::arch` AVX | 55 | 1.0x |
| | SBCL | `sb-simd` `f64.4` | 60 | 1.1x |
| | C# | `Vector256<double>` | 62 | 1.1x |
| **parallel-simd** | Rust | `std::arch` + rayon | 5 | 1.0x |
| | SBCL | `sb-simd` + `sb-thread` | 6 | 1.2x |
| | SBCL | `sb-simd` + lparallel `pmap-reduce` | 7 | 1.4x |
| | C# | `Vector256` + PLINQ | 13 | 2.6x |

Best result per language, from its plain single-threaded loop to its fastest version:

| Lang | plain serial | best | speed-up |
|---|---:|---:|---:|
| Rust | 466 | 5 | ~95x |
| SBCL | 558 | 6 | ~95x |
| C# | 2144 (479 in a method) | 13 | ~165x |

### How it is measured

`run.sh` sets up each measurement so the table reflects the code, not the
CPU's power management:

- **Serial entries** run pinned to the fastest core (`taskset`; CPU 2 here),
  after a 100 ms busy-wait on that core. Idle cores sit at 400 MHz; without
  the warm-up, a program that starts its hot loop immediately pays for the
  clock ramp-up inside the timed region (the SIMD kernels measured 4–10 ms
  slower cold), and an unpinned run can land on a slower E-core.
- **Parallel entries** are a separate run of the same program, after a
  100 ms busy-wait on all cores.
- `WARMUP=0` disables the warm-up; `WARMUP=0.3` lengthens it.

**Run on AC power.** On battery this laptop caps its clock and every result
is ~15–20% slower (e.g. Rust serial 566 ms instead of 466).

## What the groups mean

| Group | Algorithm |
|---|---|
| serial / parallel | The original programs. One running total (per thread). |
| *-8acc | 8 independent accumulators, counter kept as a double. Same code in all three. |
| *-simd | Explicit AVX: 4 vector accumulators × 4 doubles = 16 running sums. Same code in all three. |

All parallel `-8acc`/`-simd` variants split the range into 256 chunks, so idle
threads can pick up more work.

## Why Rust wins every group (and why it mostly doesn't matter)

**1. The plain loop is bound by waiting on the previous addition, not by the
language.** `sum += i` makes every addition wait for the one before it. Rust,
SBCL and C#-in-a-method all hit that limit; Rust and SBCL even produce the
identical (slightly wrong) sum `500000000067109000`, which means they add in
exactly the same order. SBCL's extra ~20% is per-iteration overhead: it removes
and re-adds the type tag on the fixnum loop counter (`SAR`/`INC`/`LEA`) and
converts int to double in the loop (see `sbcl/experiments.lisp`; keeping the
counter as a double saves ~25%).

**2. The original C# was 4.5× slower because of a JIT problem, not because of
C#.** `sum` has to survive a function call after the loop (the stopwatch
read), and the JIT handles that by storing `sum` to the stack on every
iteration. See [Why the original C# loop is slow](#why-the-original-c-loop-is-slow)
below. Rearranged so `sum` isn't needed after a call, the same loop runs as
fast as Rust.

**3. Floating-point addition can't be reordered automatically.** No compiler is
allowed to split a single `sum += x` chain into several partial sums, because
that changes the rounding. Using several accumulators by hand removes the wait
between additions and gives a 2–9× speed-up in all three languages. It also
makes the result *more* accurate: every 8-accumulator and SIMD version gets
the exact answer `500000000500000000`.

**4. Rust's remaining lead in `-8acc` comes from its compiler (LLVM)
auto-vectorizing.** Given 8 independent accumulators, LLVM packs them into
2-wide SSE2 registers (`addpd` in the binary); the .NET JIT and SBCL keep one
double per instruction (`addsd`). That is the whole 173 vs 249 ms gap.

**5. With explicit SIMD the languages are within 10%.** Once the program
spells out the vector instructions, Rust (`std::arch`, 55 ms), SBCL
(`sb-simd`, 60 ms) and C# (`Vector256`, 62 ms) all run a loop of `vaddpd ymm`
instructions. SBCL's loop has a few extra register copies and constant
reloads; `sbcl/push-experiments.lisp` shows that removing them barely
matters, and that 8 vector accumulators are slower because they need more
than the 16 AVX registers.

**6. In parallel, scheduling overhead matters.** This CPU has three kinds of
core at different speeds, so splitting into 16 equal pieces leaves fast cores
idle while slow ones finish; rayon's work stealing and 256-chunk queues avoid
that. SBCL with lparallel's `pmap-reduce` over 256 chunks (40 ms) almost
matches rayon, while the hand-rolled 16-thread split takes 70 ms with the same
per-chunk loop. With the faster 8-accumulator and SIMD loops, lparallel ties
or trails the hand-rolled `sb-thread` queue by ~1 ms (17 vs 17 ms, 7 vs 6 ms),
likely its fixed cost for creating the pool and scheduling tasks, which
weighs more as the work shrinks. At 5–15 ms, fixed costs also show: thread-pool start-up, and for C#
PLINQ set-up plus the JIT still optimizing the kernel during the timed run. PLINQ
per element (283 ms) is slow because it processes a billion tiny items through
generic iterator calls. Give it 256 chunks and it is fine.

**In short:** Rust has no runtime, no JIT warm-up and no tagged integers, and
LLVM does more automatic optimization. With the same algorithm and the same
instructions written out, all three end up close together.

## Why the original C# loop is slow

The original program (`csharp/Program.cs`) has its loop in top-level `Main`;
`csharp-fn/Program.cs` moves the same loop into `static double Sum(int)` and
runs 4.5× faster. The cause turned out **not** to be `Main`, and **not**
on-stack replacement (OSR): the slowdown appears whenever `sum` has to survive a
function call made after the loop.

### What the machine code shows

**Original** (`asm/csharp-main.asm`, Tier1-OSR) — 2159 ms:

```asm
G_M000_IG03:
       vxorps    xmm1, xmm1, xmm1
       vcvtsi2sd xmm1, xmm1, eax        ; (double)i
       vaddsd    xmm0, xmm0, xmm1       ; sum += i
       vmovsd    qword ptr [rbp+0x50], xmm0   ; <-- store sum to the stack
       inc       eax
       cmp       eax, 0x3B9ACA00
       jle       SHORT G_M000_IG07
       ...
G_M000_IG07:
       vmovsd    xmm0, qword ptr [rbp+0x50]   ; <-- reload sum from the stack
       jmp       SHORT G_M000_IG03
```

**Loop in its own method** (`asm/csharp-method.asm`, Tier1-OSR) — 486 ms:

```asm
G_M000_IG03:
       vxorps    xmm1, xmm1, xmm1
       vcvtsi2sd xmm1, xmm1, eax        ; (double)i
       vaddsd    xmm0, xmm0, xmm1       ; sum += i   (stays in xmm0)
       inc       eax
       cmp       eax, edi
       jle       SHORT G_M000_IG03
```

In the slow version every iteration stores `sum` to the stack and reads it
back, and the next addition has to wait for that round trip. Each iteration
then costs the store→load forwarding latency *plus* the add instead of just the
add: roughly 4× the cycles, matching the 4.5× slowdown.

### Ruling out OSR

Both versions are first compiled as unoptimized Tier0 code and switched to an
optimized Tier1-OSR version mid-loop, so OSR was the first suspect.

| JIT setting | original (`Main`) | `csharp-fn` (method) |
|---|---:|---:|
| default (tiered + OSR) | 2174 ms | 488 ms |
| `DOTNET_TC_OnStackReplacement=0` | 2159 ms | 2151 ms |
| `DOTNET_TieredCompilation=0` (FullOpts, no OSR) | 2171 ms | 487 ms |
| `DOTNET_TieredPGO=0` | 2170 ms | 488 ms |

- Disabling OSR makes *both* slow: a method called only once then never leaves
  Tier0, which keeps every local on the stack. That doesn't separate the two.
- Disabling tiering compiles everything fully optimized from the start, with no
  OSR at all. `Main` is still slow, and its FullOpts loop still contains the
  same store and reload. So OSR isn't the cause.

### Isolating the cause

Four small programs in `jit-variants/` (run with `./jit-variants.sh` in the
container):

| Variant | Time | Stack store in loop? |
|---|---:|---|
| A: `Main`, stopwatch read *before* printing `sum` (the original pattern) | 2176 ms | yes |
| B: `Main`, print `sum` first, then read the stopwatch | 506 ms | no |
| C: separate method, stopwatch read after the loop, `sum` returned afterwards | 2163 ms | yes |
| D: separate method, nothing after the loop (what `csharp-fn` does) | 502 ms | no |

`Main` can be fast (B) and a separate method can be slow (C). What decides it is
whether `sum` is still needed after a call that follows the loop. In the
original, `run.ElapsedMilliseconds` calls `GetTimestamp()` before `sum` is
printed.

### Why a call after the loop matters

1. **Function calls overwrite every XMM register on Linux x64.** The calling
   convention there has no XMM registers that are preserved across a call, so
   a `double` needed after a call must be saved to the stack before it.
2. **The JIT saves `sum` in the wrong place.** Ideally it would store `sum`
   once, after the loop and just before the call. Instead it stores `sum`
   wherever the variable is written, which is inside the loop, so the store and
   reload land on the chain of additions. RyuJIT's register allocator is a
   linear-scan design built for fast compilation and doesn't move these saves
   out of loops; LLVM does, which is why Rust doesn't have this problem. (This
   is read from the generated code and the experiments above, not checked
   against the JIT's source.)
3. **`csharp-fn` was fast only by accident of ordering:** `Sum` returns before
   any call, and the stopwatch is read later in `Main`.

**Windows may differ.** Windows x64 keeps XMM6–XMM15 preserved across calls,
so the JIT could keep `sum` in one of those and the original might be fast
there. Not tested.

**Takeaway for C#:** in a hot loop, watch for floating-point values that are
still needed after a call made *after* the loop. Using the result before
making other calls (variant B) or returning it from a small method (D) both
avoid the problem.

To regenerate the listings:

```sh
mkdir -p asm
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -v "$PWD/asm:/out" perf-comp ./jit-asm.sh
```

The other languages' code can be inspected with `objdump -d rust/target/release/<bin>`
and `(disassemble 'kernel)` in SBCL.

## Project layout

| Path | What |
|---|---|
| `csharp/` | Original C# program (loop in top-level `Main`) |
| `csharp-fn/` | Same loop in its own method |
| `csharp-parallel/` | PLINQ per element + `Parallel.ForEach` with a range partitioner |
| `csharp-opt/` | 8 accumulators; parallel = PLINQ over 256 chunks |
| `csharp-simd/` | `Vector256<double>`; parallel = PLINQ over 256 chunks |
| `rust/src/main.rs` | Original Rust program (rayon) |
| `rust/src/bin/serial.rs` | Single-threaded `iter().sum()` |
| `rust/src/bin/opt.rs` | 8 accumulators; parallel = rayon over 256 chunks |
| `rust/src/bin/simd.rs` | `std::arch` AVX intrinsics; parallel = rayon over 256 chunks |
| `sbcl/sum.lisp` | Serial loop + 16 threads with equal split |
| `sbcl/sum-opt.lisp` | 8 accumulators; parallel = threads pulling 256 chunks from an atomic counter |
| `sbcl/sum-simd.lisp` | `sb-simd` `f64.4`; same parallel scheme |
| `sbcl/experiments.lisp` | SBCL tuning experiments (double counter, 4/8 accumulators, chunk counts) |
| `sbcl/push-experiments.lisp` | Macro-generated SIMD kernel variants with inner-loop instruction counts |
| `sbcl/sum-lparallel.lisp` | lparallel `pmap-reduce` over 256 chunks with three kernels: plain loop, 8 accumulators, `sb-simd` |
| `sbcl/lparallel-experiments.lisp` | lparallel styles compared (`pmap-reduce`, `preduce`, futures, `pmapcar`) |
| `sbcl/build*.lisp` | Build each Lisp file into a standalone executable |
| `run.sh` | Runs everything `RUNS` times (serial pinned to the fastest core, with CPU warm-up) and prints the comparison table |
| `jit-asm.sh` | Dumps the .NET JIT assembly for `csharp/` and `csharp-fn/` |
| `asm/` | Saved JIT listings |
| `beauty-competition.md` | The most succinct version in each language, timed |
| `jit-variants/` | Four small C# programs isolating the JIT problem |
| `jit-variants.sh` | Runs them under default and FullOpts JIT settings |

## Caveats

- Timings are wall-clock from inside each program and include thread-pool
  start-up and, for C#, JIT compilation; there is no in-process warm-up run,
  only the CPU warm-up described in [How it is measured](#how-it-is-measured).
- Floating-point sums differ between variants because addition order differs;
  the exact answer is 500000000500000000.
- Rust is built for generic x86-64; its `-8acc` version uses SSE2. The explicit
  SIMD versions check for AVX (Rust/C#) or require it (SBCL `sb-simd-avx`).
- For parallel runs the OS decides which core type each thread runs on,
  which adds some run-to-run noise.
