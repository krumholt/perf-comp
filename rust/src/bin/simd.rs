// Explicit AVX (256-bit) version. Same algorithm as csharp-simd and
// sbcl/sum-simd.lisp: 4 vector accumulators x 4 doubles = 16 running sums.
use rayon::prelude::*;
use std::arch::x86_64::*;
use std::time::Instant;

const TARGET: u32 = 1_000_000_000;
const CHUNKS: u32 = 256;

#[target_feature(enable = "avx")]
unsafe fn kernel_avx(from: u32, to: u32) -> f64 {
    let n = (to - from + 1) as u64;
    let x = from as f64;
    // counters: [x..x+3], [x+4..x+7], [x+8..x+11], [x+12..x+15]
    let mut v0 = _mm256_setr_pd(x, x + 1.0, x + 2.0, x + 3.0);
    let mut v1 = _mm256_add_pd(v0, _mm256_set1_pd(4.0));
    let mut v2 = _mm256_add_pd(v0, _mm256_set1_pd(8.0));
    let mut v3 = _mm256_add_pd(v0, _mm256_set1_pd(12.0));
    let step = _mm256_set1_pd(16.0);
    let (mut a0, mut a1, mut a2, mut a3) =
        (_mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd());
    for _ in 0..n / 16 {
        a0 = _mm256_add_pd(a0, v0); v0 = _mm256_add_pd(v0, step);
        a1 = _mm256_add_pd(a1, v1); v1 = _mm256_add_pd(v1, step);
        a2 = _mm256_add_pd(a2, v2); v2 = _mm256_add_pd(v2, step);
        a3 = _mm256_add_pd(a3, v3); v3 = _mm256_add_pd(v3, step);
    }
    let acc = _mm256_add_pd(_mm256_add_pd(a0, a1), _mm256_add_pd(a2, a3));
    let mut lanes = [0.0f64; 4];
    _mm256_storeu_pd(lanes.as_mut_ptr(), acc);
    let mut sum = (lanes[0] + lanes[1]) + (lanes[2] + lanes[3]);
    // scalar tail
    let mut t = x + (n / 16 * 16) as f64;
    for _ in 0..n % 16 { sum += t; t += 1.0; }
    sum
}

fn kernel(from: u32, to: u32) -> f64 {
    assert!(is_x86_feature_detected!("avx"));
    unsafe { kernel_avx(from, to) }
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
