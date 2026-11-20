// Same loop as csharp/Program.cs, moved into its own method. In top-level
// Main the JIT (OSR) spills `sum` to memory every iteration; here it stays
// in a register.
using System.Diagnostics;
const int target = 1000000000;
Stopwatch run = Stopwatch.StartNew();
double sum = Sum(target);
var adding_time = run.ElapsedMilliseconds;
Console.WriteLine($"Sum: {sum},  Sum Time: {adding_time} ms");

static double Sum(int target)
{
    double sum = 0.0;
    for (int i = 1; i <= target; i++)
        sum += i;
    return sum;
}
