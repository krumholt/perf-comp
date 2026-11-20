use rayon::iter::{ParallelIterator,IntoParallelIterator};
use std::time::Instant;

fn main() {
    const TARGET: u32 = 1_000_000_000;
    let run = Instant::now();
    let sum = (1..=TARGET).into_par_iter()
        .map(|x| x as f64)
        .reduce(||0.0, |x , y| x + y);

    let sum_time_elapsed = run.elapsed().as_millis();
    println!("Sum: {sum} Sum Time {sum_time_elapsed} ms");
}
