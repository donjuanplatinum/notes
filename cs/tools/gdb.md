# GDB调试器
## Cli
### 运行
gdb Program [core dump] # 启动gdb
gdb --args program args... # 传入程序的args
adb --pid PID # gdb附加到进程

## 交互式
- 文件
set args 指定args
- 进程
run/r 运行程序
kill 杀掉进程
list/l 列出源代码
frame/f 现在位置

- 断点
break <where> 下断点
delete <breakpoint#> 删断点
clear 删所有断点
enable <breakpoint#> 启用断点
disable <breakpoint#> 禁用断点
info <breakpoint> 查看断点信息


- 观察点
watch <where> 下观察点
delete/enable/disable <watchpoint#> 类似


- <where>的类型
函数名
行号
文件:行号

- Conditions
break/watch <where> if <condition>

- 变量
print/p [val] 打印变量
info local 查看本地变量
## 概念
这些变量可以用`info`命令打出
- `locals`: 局部变量
- `args`: 函数参数
## 例子
这里举一个调试算法的例子

```rust
impl Solution {
    pub fn path_existence_queries(n: i32, nums: Vec<i32>, max_diff: i32, queries: Vec<Vec<i32>>) -> Vec<bool> {
	let mut block: Vec<(usize,usize)> = vec!();
	let mut l_idx: usize = 0;
        for i in 1..(n as usize) {
	    if nums[i] - nums[i-1] > max_diff {
		block.push((l_idx,i - 1));
		l_idx = i;
	    }
	}
	println!("{:?}",block);
	vec![]
    }
}

```

我们想要调试算法 首先`cargo build`以debug模式编译

然后搜索函数的名字 `info func path_exist` 我们得到一个列表

```gdb
(gdb) info func path_exist
All functions matching regular expression "path_exist":

File library/std/src/../../backtrace/src/symbolize/gimli/elf.rs:
399:    static fn std::backtrace_rs::symbolize::gimli::elf::debug_path_exists();

File src/solution.rs:
3:      static fn work::Solution::path_existence_queries(i32, alloc::vec::Vec<i32, alloc::alloc::Global>, i32, alloc::vec::Vec<alloc::vec::Vec<i32, alloc::alloc::Global>, alloc::alloc::Global>) -> alloc::vec::Vec<bool, alloc::alloc::Global>;

```

根据这个名字我们可以下断点

```
(gdb) b work::Solution::path_existence_queries
```

然后 运行程序

```
(gdb) r
```

接下来 查看目前的变量

```
(gdb) info loc
n = 201326596
```

我们现在看看我们在程序的哪里 显示我们在`work::main`的第4行

```
(gdb) fra
#0  work::main () at src/main.rs:6
6           let n = 4;
```
