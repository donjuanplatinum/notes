# Criterion
最常用的Rust性能评测工具

特性:
- 统计学原理: 基于统计学评估
- 图表绘制: 使用Gnuplot画图
- 稳定
## features
- [default]plotters: 开启plotters
- [default]rayon: 多线程的库
- async: 异步
- async_tokio: tokio支持
- async_std: async_std支持
- csv_output: csv导出
- html_reports: html导出
## 快速上手
添加进`Cargo.toml`

```toml

[dependencies]
criterion = { version = "0.5", features = ["html_reports"]}

[[bench]]
name = "my_benchmark"
harness = false
```

紧接着 创建`$PROJECT/benches/my_benchmark.rs`
```rust
use std::hint::black_box;
use criterion::{criterion_group,criterion_main,Criterion};

fn sum_to_n1(n: i32) -> i32 {
    let mut s = 0;
    for i in 1..=n{
	s += i;
	
    }
    s
}

fn sum_to_n2(n: i32) -> i32 {
    let mut s = 0;
    for i in 1..n+1{
	s += i;
    }
    s
}

fn formula(n: i32)     -> i32 {
    n * (n+1)/2 
}

fn criterion_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("sum");
    group.bench_function("rangeinclusive",|b| b.iter(|| sum_to_n1(black_box(10))));
    group.bench_function("range",|b| b.iter(|| sum_to_n2(black_box(10))));
    group.bench_function("formula",|b| b.iter(|| formula(black_box(10))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);

```

然后使用cargo bench
## 结果
```
sum/rangeinclusive      time:   [18.703 ns 18.802 ns 18.929 ns]
Found 11 outliers among 100 measurements (11.00%)
  2 (2.00%) high mild
  9 (9.00%) high severe
sum/range               time:   [1.4168 ns 1.4221 ns 1.4270 ns]
Found 1 outliers among 100 measurements (1.00%)
  1 (1.00%) low mild
sum/formula             time:   [1.0076 ns 1.0141 ns 1.0239 ns]
Found 9 outliers among 100 measurements (9.00%)
  1 (1.00%) high mild
  8 (8.00%) high severe
```

其中
- time: 代表时间 [最小时间,平均时间,最高时间]
- found x outliers: x个高群值
