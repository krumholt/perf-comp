using System.Diagnostics;

const int target = 1000000000;

Stopwatch run = Stopwatch.StartNew();
double sum = 0.0;
for (int i = 1; i <= target; i++)
    sum += i;
var adding_time = run.ElapsedMilliseconds;
Console.WriteLine($"Sum: {sum},  Sum Time: {adding_time} ms");
