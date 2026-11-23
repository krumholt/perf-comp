import java.util.stream.IntStream;

// SumInt with reduce(0.0, Double::sum) instead of DoubleStream.sum(): a plain
// running sum per chunk instead of compensated (Kahan) summation. A separate
// class so its native-image binary contains only this one stream pipeline.
public class SumIntReduce {
     public static void main(String[] args) {
         long before = System.currentTimeMillis();
         double sum = IntStream.range(1, 1_000_000_000 + 1).parallel().mapToDouble(i -> (double) i).reduce(0.0, Double::sum);
         System.out.println("Sum: " + sum);
         long elapsed = System.currentTimeMillis() - before;
         System.out.println("Sum Time: " + elapsed + " ms");
     }
}
