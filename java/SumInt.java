import java.util.stream.IntStream;

// The original Java program: a parallel stream, summed with DoubleStream.sum().
// Only the two print lines differ from the submitted version, so run.sh can
// read them; the timed region (including the first println) is unchanged.
public class SumInt {
     public static void main(String[] args) {
         long before = System.currentTimeMillis();
         double sum = IntStream.range(1, 1_000_000_000 + 1).parallel().mapToDouble(i -> (double) i).sum();
         System.out.println("Sum: " + sum);
         long elapsed = System.currentTimeMillis() - before;
         System.out.println("Sum Time: " + elapsed + " ms");
     }
}
