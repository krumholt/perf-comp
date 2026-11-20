// Explicit AVX (256-bit) version. Same algorithm as rust/src/bin/simd.rs and
// sbcl/sum-simd.lisp: 4 vector accumulators x 4 doubles = 16 running sums.
using System.Diagnostics;
using System.Runtime.Intrinsics;

const int target = 1_000_000_000;
const int chunks = 256;

if (!Vector256.IsHardwareAccelerated)
    Console.Error.WriteLine("warning: Vector256 is not hardware accelerated");

var run = Stopwatch.StartNew();
var sum = Kernel(1, target);
Console.WriteLine($"Serial   Sum: {sum},  Sum Time: {run.ElapsedMilliseconds} ms");

int chunk = (target + chunks - 1) / chunks;
run.Restart();
sum = ParallelEnumerable.Range(0, chunks)
    .Select(k => Kernel(k * chunk + 1, Math.Min(target, (k + 1) * chunk)))
    .Sum();
Console.WriteLine($"Parallel Sum: {sum},  Sum Time: {run.ElapsedMilliseconds} ms");

static double Kernel(int from, int to)
{
    long n = (long)to - from + 1;
    double x = from;
    // counters: [x..x+3], [x+4..x+7], [x+8..x+11], [x+12..x+15]
    var v0 = Vector256.Create(x, x + 1, x + 2, x + 3);
    var v1 = v0 + Vector256.Create(4.0);
    var v2 = v0 + Vector256.Create(8.0);
    var v3 = v0 + Vector256.Create(12.0);
    var step = Vector256.Create(16.0);
    Vector256<double> a0 = default, a1 = default, a2 = default, a3 = default;
    for (long i = 0; i < n / 16; i++)
    {
        a0 += v0; v0 += step;
        a1 += v1; v1 += step;
        a2 += v2; v2 += step;
        a3 += v3; v3 += step;
    }
    var acc = (a0 + a1) + (a2 + a3);
    double sum = (acc[0] + acc[1]) + (acc[2] + acc[3]);
    // scalar tail
    double t = x + n / 16 * 16;
    for (long i = 0; i < n % 16; i++) { sum += t; t += 1; }
    return sum;
}
