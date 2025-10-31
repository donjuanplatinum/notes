# Clap
CLI命令行解析库

## 一个简单的示例
```rust
use clap::{Parser,Subcommand};
#[derive(Parser)]
#[command(name = "ml")]
#[command(about = "Mnist CNN", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
// 两个子命令 train和infer
    Train {
	// 子命令train的参数
	#[arg(short, long, default_value_t = 10)]
	epochs: usize,
	#[arg(short, long, default_value_t = 0.01)]
	learning_rate: f64,
	#[arg(short,long,default_value_t = 32)]
	batch_size: usize,
    },
    Infer {
	// 子命令infer的参数
        #[arg(short, long)]
        image_path: String,
	#[arg(short,long)]
	model_path: String,
    },
}
```
