using System.Collections.Concurrent;
using System.Diagnostics;

const int target = 1_000_000_000;

// PLINQ: the direct equivalent of rayon's into_par_iter().map().reduce()
var run = Stopwatch.StartNew();
var sum = ParallelEnumerable.Range(1, target)
    .Select(x => (double)x)
    .Sum();
Console.WriteLine($"PLINQ        Sum: {sum},  Sum Time: {run.ElapsedMilliseconds} ms");

// Range partitioner: hand each worker a chunk and run a tight loop over it
run.Restart();
double total = 0.0;
object gate = new();
Parallel.ForEach(
    Partitioner.Create(1, target + 1, target / (Environment.ProcessorCount * 4)),
    () => 0.0,
    (range, _, local) =>
    {
        for (int i = range.Item1; i < range.Item2; i++)
            local += i;
        return local;
    },
    local => { lock (gate) total += local; });
Console.WriteLine($"Partitioner  Sum: {total},  Sum Time: {run.ElapsedMilliseconds} ms");
