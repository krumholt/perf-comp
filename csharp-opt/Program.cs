// Same algorithm as sbcl/sum-opt.lisp and rust/src/bin/opt.rs: 8 independent
// accumulators with a double counter; parallel = 256 chunks.
using System.Diagnostics;

const int target = 1_000_000_000;
const int chunks = 256;

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
    double s0 = 0, s1 = 0, s2 = 0, s3 = 0, s4 = 0, s5 = 0, s6 = 0, s7 = 0;
    double x = from;
    long n = (long)to - from + 1;
    for (long i = 0; i < n / 8; i++)
    {
        s0 += x;     s1 += x + 1; s2 += x + 2; s3 += x + 3;
        s4 += x + 4; s5 += x + 5; s6 += x + 6; s7 += x + 7;
        x += 8;
    }
    for (long i = 0; i < n % 8; i++) { s0 += x; x += 1; }
    return ((s0 + s1) + (s2 + s3)) + ((s4 + s5) + (s6 + s7));
}
