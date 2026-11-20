using System.Diagnostics;
const int target = 1000000000;
Stopwatch run = Stopwatch.StartNew();
double sum = 0.0;
for (int i = 1; i <= target; i++) sum += i;
Console.WriteLine(sum);                   // sum consumed first
Console.WriteLine($"{run.ElapsedMilliseconds} ms");
