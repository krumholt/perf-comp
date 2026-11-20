// Same algorithm as sbcl/sum-opt.lisp and csharp-opt: 8 independent
// accumulators with a double-float counter; parallel = 256 chunks.
use rayon::prelude::*;
use std::time::Instant;

const TARGET: u32 = 1_000_000_000;
const CHUNKS: u32 = 256;

fn kernel(from: u32, to: u32) -> f64 {
    let mut s = [0.0f64; 8];
    let mut x = from as f64;
    let n = (to - from + 1) as u64;
    for _ in 0..n / 8 {
        for (k, acc) in s.iter_mut().enumerate() {
            *acc += x + k as f64;
        }
        x += 8.0;
    }
    for _ in 0..n % 8 {
        s[0] += x;
        x += 1.0;
    }
    ((s[0] + s[1]) + (s[2] + s[3])) + ((s[4] + s[5]) + (s[6] + s[7]))
}

fn main() {
    let run = Instant::now();
    let sum = kernel(1, TARGET);
    println!("Serial   Sum: {sum} Sum Time {} ms", run.elapsed().as_millis());

    let chunk = TARGET.div_ceil(CHUNKS);
    let run = Instant::now();
    let sum: f64 = (0..CHUNKS)
        .into_par_iter()
        .map(|k| kernel(k * chunk + 1, TARGET.min((k + 1) * chunk)))
        .sum();
    println!("Parallel Sum: {sum} Sum Time {} ms", run.elapsed().as_millis());
}
