# Beauty competition

The most succinct idiomatic way to sum 1..1,000,000,000 as doubles in each
language: no hand-tuning, no accumulators, no SIMD. Just the code you would
write first.

Times are from 3 runs inside the project's Docker image (same machine as the
[README](README.md): Intel Core Ultra X7 358H, 16 cores). Only the expression
shown is timed.

## Single-threaded

### Rust: 476 ms

```rust
let sum: f64 = (1..=1_000_000_000u32).map(f64::from).sum();
```

### SBCL: 481 ms

```lisp
(loop for i fixnum from 1 to 1000000000 sum (float i 1d0) of-type double-float)
```

Drop the two type declarations and it still works, but takes **2,800 ms**:

```lisp
(loop for i from 1 to 1000000000 sum (float i 1d0))
```

Without the declarations SBCL can't prove the sum stays a double, so every
addition goes through generic arithmetic. The declared version, compiled
with default optimization settings, is even faster than the hand-tuned
`sbcl/sum.lisp` (584 ms).

### C#: 2,200 ms

```csharp
var sum = Enumerable.Range(1, 1_000_000_000).Sum(x => (double)x);
```

Beautiful, but LINQ calls the iterator and the lambda once per element. The
plain loop in its own method (`csharp-fn/`) is not much longer and runs in
486 ms:

```csharp
static double Sum(int n) { double s = 0; for (int i = 1; i <= n; i++) s += i; return s; }
```

## Parallel

### Rust: 37 ms

```rust
use rayon::prelude::*;
let sum: f64 = (1..=1_000_000_000u32).into_par_iter().map(f64::from).sum();
```

One import and `iter` becomes `into_par_iter`. Rayon splits the range
adaptively across all cores.

### SBCL: 42 ms (lparallel)

```lisp
(setf lparallel:*kernel* (lparallel:make-kernel 16))
(lparallel:pmap-reduce
 (lambda (j) (loop for i fixnum from (1+ (* j 3906250)) to (* (1+ j) 3906250)
                   sum (float i 1d0) of-type double-float))
 #'+ (alexandria:iota 256) :parts 256)
```

[lparallel](https://lparallel.org) (installed via Quicklisp) has no numeric
range type, so this maps over 256 chunk indices and sums each chunk with the
single-threaded loop. Two details matter:

- **`:parts 256`**: without it, `pmap-reduce` groups the input into one part
  per worker, so 256 chunks behave like 16 big ones (~62 ms instead of ~42 ms).
  With 256 parts, idle workers can take more chunks, the same way rayon does.
- **The kernel (thread pool) has to be created explicitly**; rayon does this
  for you. Its creation is included in the 42 ms (about 1 ms).

Other lparallel styles measured in `sbcl/lparallel-experiments.lisp`, all with
256 chunks: futures 40–42 ms, `pmapcar` + `reduce` 41–46 ms, `preduce` over
`pmap` 50–65 ms.

Without lparallel, plain `sb-thread` takes 44 ms with 16 equal chunks, but
needs more ceremony:

```lisp
(reduce #'+ (mapcar #'sb-thread:join-thread
                    (loop for j below 16
                          collect (let ((lo (1+ (* j 62500000))) (hi (* (1+ j) 62500000)))
                                    (sb-thread:make-thread
                                     (lambda () (loop for i fixnum from lo to hi
                                                      sum (float i 1d0) of-type double-float)))))))
```

### C#: 277 ms

```csharp
var sum = ParallelEnumerable.Range(1, 1_000_000_000).Sum(x => (double)x);
```

As pretty as Rust's, but it has the same per-element LINQ overhead spread
across 16 cores. Handing PLINQ coarse chunks instead gets it to ~25 ms (see
`csharp-opt/`).

## Scoreboard

| | Single-threaded | Parallel | Lines (parallel) |
|---|---:|---:|---:|
| Rust | 476 ms | 37 ms | 2 |
| SBCL | 481 ms | 42 ms | 5 |
| C# | 2,200 ms | 277 ms | 1 |

**Verdict:**
- **Rust wins on both looks and speed.** Its iterator chains compile down to
  the same tight loop you'd write by hand, and going parallel is a one-word
  change.
- **C#'s LINQ looks just as good, but it costs 4–7× in speed**, because the
  JIT doesn't reduce `Range().Sum(lambda)` to a plain loop.
- **SBCL is as fast as Rust** if you add two type declarations. In
  parallel, lparallel gets within ~10% of rayon, but you have to split the
  range into chunks yourself and set `:parts`.
