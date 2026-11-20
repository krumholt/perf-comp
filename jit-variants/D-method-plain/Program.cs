using System.Diagnostics;
var run = Stopwatch.StartNew();
double sum = Sum(1000000000);
Console.WriteLine($"{sum} {run.ElapsedMilliseconds} ms");
static double Sum(int target)
{
    double sum = 0.0;
    for (int i = 1; i <= target; i++) sum += i;
    return sum;
}
