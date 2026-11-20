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

## Toolchain and machine

| | |
|---|---|
| C# | .NET 9.0 SDK, Release build, default tiered JIT |
| Rust | rustc 1.100 stable, `--release` (no `target-cpu=native`) |
| SBCL | 2.6.10 (official binary), `(optimize (speed 3) (safety 0))`, saved as an executable |
| Base image | `mcr.microsoft.com/dotnet/sdk:9.0-noble` (Ubuntu 24.04; SBCL 2.6.10 needs glibc ≥ 2.38) |
| CPU | Intel Core Ultra X7 358H, AVX2 (no AVX-512), 16 cores: 4 P-cores @ 4.7 GHz, 8 E-cores @ 3.7 GHz, 4 low-power E-cores @ 3.3 GHz |

## Results

Times in ms; "vs best" compares each average to the fastest entry in the same group.

| Group | Lang | Variant | Avg (ms) | vs best |
|---|---|---|---:|---:|
| **serial** | Rust | `iter().sum()` | 478 | 1.0x |
| | C# | for loop in its own method | 486 | 1.0x |
| | SBCL | `loop` | 584 | 1.2x |
| | C# | for loop in top-level `Main` (original) | 2159 | 4.5x |
| **parallel** | Rust | rayon | 37 | 1.0x |
| | C# | `Parallel.ForEach` + range partitioner | 43 | 1.1x |
| | SBCL | `sb-thread` × 16, equal split | 68 | 1.8x |
| | C# | PLINQ (per element) | 287 | 7.7x |
| **serial-8acc** | Rust | 8 accumulators | 166 | 1.0x |
| | SBCL | 8 accumulators | 237 | 1.4x |
| | C# | 8 accumulators | 242 | 1.5x |
| **parallel-8acc** | Rust | rayon, 256 chunks | 11 | 1.0x |
| | SBCL | `sb-thread`, 256 chunks | 16 | 1.5x |
| | C# | PLINQ, 256 chunks | 27 | 2.4x |
| **serial-simd** | Rust | `std::arch` AVX | 67 | 1.0x |
| | C# | `Vector256<double>` | 71 | 1.0x |
| | SBCL | `sb-simd` `f64.4` | 74 | 1.1x |
| **parallel-simd** | Rust | `std::arch` + rayon | 5 | 1.0x |
| | SBCL | `sb-simd` + `sb-thread` | 6 | 1.2x |
| | C# | `Vector256` + PLINQ | 14 | 2.6x |

Best result per language, from its plain single-threaded loop to its fastest version:

| Lang | plain serial | best | speed-up |
|---|---:|---:|---:|
| Rust | 478 | 5 | ~95x |
| SBCL | 584 | 6 | ~95x |
| C# | 2159 (486 in a method) | 14 | ~150x |

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
C#.** See [The C# JIT: `Main` vs a method](#the-c-jit-main-vs-a-method) below.
The same loop moved into its own method runs as fast as Rust.

**3. Floating-point addition can't be reordered automatically.** No compiler is
allowed to split a single `sum += x` chain into several partial sums, because
that changes the rounding. Using several accumulators by hand removes the wait
between additions and gives a 2–9× speed-up in all three languages. It also
makes the result *more* accurate: every 8-accumulator and SIMD version gets
the exact answer `500000000500000000`.

**4. Rust's remaining lead in `-8acc` comes from its compiler (LLVM)
auto-vectorizing.** Given 8 independent accumulators, LLVM packs them into
2-wide SSE2 registers (`addpd` in the binary); the .NET JIT and SBCL keep one
double per instruction (`addsd`). That is the whole 166 vs ~240 ms gap.

**5. With explicit SIMD the languages are within 10%.** Once the program
spells out the vector instructions, Rust (`std::arch`), C# (`Vector256`) and
SBCL (`sb-simd`) all run a loop of `vaddpd ymm` instructions at ~70 ms.

**6. In parallel, scheduling overhead matters.** This CPU has three kinds of
core at different speeds, so splitting into 16 equal pieces leaves fast cores
idle while slow ones finish; rayon's work stealing and 256-chunk queues avoid
that. At 5–15 ms, fixed costs also show: thread-pool start-up, and for C#
PLINQ set-up plus the JIT still optimizing the kernel during the timed run. PLINQ
per element (287 ms) is slow because it processes a billion tiny items through
generic iterator calls. Give it 256 chunks and it is fine.

**In short:** Rust has no runtime, no JIT warm-up and no tagged integers, and
LLVM does more automatic optimization. With the same algorithm and the same
instructions written out, all three end up close together.

## The C# JIT: `Main` vs a method

The original C# program has its loop directly in top-level statements
(`csharp/Program.cs`); `csharp-fn/Program.cs` is the identical loop moved into
`static double Sum(int target)`.

Both are compiled the same way: the method starts in quick, unoptimized Tier0
code, the loop gets hot, and the JIT swaps in an optimized **Tier1-OSR**
(on-stack replacement) version in the middle of the loop. The difference is
what the optimized code does with `sum`.

**Loop in top-level `Main`** (`asm/csharp-main.asm`, Tier1-OSR) — 2159 ms:

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

Every iteration stores `sum` to its stack slot and the back-edge block reloads
it. The reload sits on the dependency chain, so each addition now waits for
store → load forwarding (~4–5 cycles) *plus* the add, instead of just the add.
That is roughly 4× more cycles per iteration, matching the 4.5× slowdown. The
likely cause: `Main` is big (Stopwatch, string interpolation, the `Console`
call) and `sum` is used after the loop, so the register allocator keeps `sum`'s
home in its stack slot and splits its live range at the loop's back edge (not
verified against the JIT source). Turning tiered
compilation off (`DOTNET_TieredCompilation=0`) does not help (still ~2.1 s).

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

Six instructions, no memory access: `sum` lives in `xmm0` for the whole loop.
This is the textbook version of the loop, and it runs at the same speed as
Rust's (478 vs 486 ms).

**Takeaway for C#:** put hot loops in their own small methods. Top-level
statements and large methods can make the register allocator keep values in
memory.

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
| `sbcl/build*.lisp` | Build each Lisp file into a standalone executable |
| `run.sh` | Runs everything `RUNS` times and prints the comparison table |
| `jit-asm.sh` | Dumps the .NET JIT assembly for `csharp/` and `csharp-fn/` |
| `asm/` | Saved JIT listings |

## Caveats

- Timings are wall-clock from inside each program and include thread-pool
  start-up; there is no warm-up run.
- Floating-point sums differ between variants because addition order differs;
  the exact answer is 500000000500000000.
- Rust is built for generic x86-64; its `-8acc` version uses SSE2. The explicit
  SIMD versions check for AVX (Rust/C#) or require it (SBCL `sb-simd-avx`).
- The OS decides which core type each thread runs on, which adds some
  run-to-run noise, mostly in the parallel numbers.
