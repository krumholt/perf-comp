using System.Diagnostics;
var run = Stopwatch.StartNew();
var (sum, t) = Sum(1000000000, run);
Console.WriteLine($"{sum} {t} ms");
static (double, long) Sum(int target, Stopwatch run)
{
    double sum = 0.0;
    for (int i = 1; i <= target; i++) sum += i;
    var t = run.ElapsedMilliseconds;      // same pattern, but NOT in Main
    return (sum, t);
}
