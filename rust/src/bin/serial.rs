use std::time::Instant;

fn main() {
    const TARGET: u32 = 1_000_000_000;
    let run = Instant::now();
    let sum: f64 = (1..=TARGET).map(|x| x as f64).sum();

    let sum_time_elapsed = run.elapsed().as_millis();
    println!("Sum: {sum} Sum Time {sum_time_elapsed} ms");
}
