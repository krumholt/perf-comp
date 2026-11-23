import java.util.stream.IntStream;

// Variants of SumInt that take it apart, one per JVM start:
//   java Variants <variant> [reps]
//
//   par-sum     the original: parallel stream + DoubleStream.sum()
//   par-reduce  parallel stream + reduce(0.0, Double::sum)   (no compensated summation)
//   seq-sum     sequential stream + DoubleStream.sum()
//   seq-reduce  sequential stream + reduce(0.0, Double::sum)
//   loop        plain for loop in a method called once (runs as on-stack-replaced code)
//   loop-warm   same method, called only after it was compiled normally
//   kahan-warm  DoubleStream.sum()'s arithmetic written as a loop over locals, compiled normally
//
// reps > 1 repeats the measurement in the same JVM, to separate JIT warm-up
// from steady state.
public class Variants {
    static final int N = 1_000_000_000;

    static double loop(int n) {
        double s = 0;
        for (int i = 1; i <= n; i++) s += i;
        return s;
    }

    // What DoubleStream.sum() does per element: Collectors.sumWithCompensation
    // (Kahan summation) plus a plain sum kept for the infinities case.
    static double kahan(int n) {
        double hi = 0, c = 0, simple = 0;
        for (int i = 1; i <= n; i++) {
            double d = i;
            double y = d - c;
            double t = hi + y;
            c = (t - hi) - y;
            hi = t;
            simple += d;
        }
        return Double.isNaN(hi - c) ? simple : hi - c;
    }

    static double run(String v) {
        return switch (v) {
            case "par-sum"    -> IntStream.rangeClosed(1, N).parallel().mapToDouble(i -> (double) i).sum();
            case "par-reduce" -> IntStream.rangeClosed(1, N).parallel().mapToDouble(i -> (double) i).reduce(0.0, Double::sum);
            case "seq-sum"    -> IntStream.rangeClosed(1, N).mapToDouble(i -> (double) i).sum();
            case "seq-reduce" -> IntStream.rangeClosed(1, N).mapToDouble(i -> (double) i).reduce(0.0, Double::sum);
            case "loop", "loop-warm" -> loop(N);
            case "kahan-warm" -> kahan(N);
            default -> throw new IllegalArgumentException("unknown variant " + v);
        };
    }

    public static void main(String[] args) {
        String v = args[0];
        int reps = args.length > 1 ? Integer.parseInt(args[1]) : 1;
        if (v.endsWith("-warm")) {
            // Short calls until C2 has compiled the method from its normal entry,
            // so the timed call does not run on-stack-replaced code.
            double sink = 0;
            for (int r = 0; r < 20_000; r++) sink += v.equals("loop-warm") ? loop(10_000) : kahan(10_000);
            if (sink == 42) System.out.println();
        }
        for (int r = 0; r < reps; r++) {
            long t = System.nanoTime();
            double s = run(v);
            long ms = (System.nanoTime() - t) / 1_000_000;
            System.out.printf("%-10s rep %d  Sum: %.0f,  Sum Time: %d ms%n", v, r + 1, s, ms);
        }
    }
}
