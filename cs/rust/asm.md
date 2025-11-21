# asm
对Rust生成汇编的分析 以及对Rust编译器的分析

本篇会讨论 如何写出`高性能`的Rust代码

本篇分为几个章节
- 良好的优化习惯: 讲述了良好的习惯来让生成的汇编更快
- 汇编观察: 对生成的汇编的优化进行观察与思考
## 工具链
### cargo-asm
将函数生成汇编

首先我们需要安装`cargo-asm`工具

然后我们可以对函数生成汇编

```shell
cargo asm crate::function --rust
cargo asm crate::Type::method --rust
```


*尽量使用#[inline(never)] 否则一些函数会被编译器内联而使rust-asm看不到汇编*

## 良好的优化习惯
### 尽量使用开区间Range
`前闭后开是计算机领域最好的表示法`

![为什么编号应该从零开始？](https://www.cs.utexas.edu/~EWD/transcriptions/EWD08xx/EWD831.html)

![rust闭区间不会被llvm优化](https://users.rust-lang.org/t/why-does-iterator-fold-sometimes-optimize-to-a-closed-form-formula-but-a-plain-for-loop-doesnt/136331/3)

Rust编译器会对开区间`Range`有优化 这是由于C语言不流行闭区间`RangeInclusive`

出现这种情况的原因是，包含范围需要进行特殊检查，以处理类似这样的情况1..=i32::MAX，这种情况无法用排除范围来表示。

使用for循环时，Rust 会反复.next()调用迭代器。每次调用时，它都必须检查当前迭代是否是上一次迭代的特殊情况。而使用.fold()`for` 循环.for_each()，迭代器可以遍历所有迭代1..n，然后单独执行n最后一次迭代，这更容易被 LLVM 优化。

#### 代码与汇编
这里贴出一个前n项和的代码
```rust
pub fn sum_to_n(n: i32) -> i32 {
    let mut s = 0;
    for i in 1..=n{
	s += i;
	
    }
    s
}
```

```rust
pub fn sum_to_n(n: i32) -> i32 {
    let mut s = 0;
    for i in 1..n+1{
	s += i;
    }
    s
}
```

两段代码对应的x86汇编是
```asm
// 判断edi寄存器是否为0
 test    edi, edi 
// 为0则跳转到.LBB0_1
 jle     .LBB0_1
 // 将ecx的值复制为1
 mov     ecx, 1
 // eax=0
 xor     eax, eax
.LBB0_3:
// edx=0
 xor     edx, edx
 // 比较ecx - edi与0 写入标志位
 cmp     ecx, edi
 // 将标志位结果写入sil
 setl    sil
 add     eax, ecx
 cmp     ecx, edi
 jge     .LBB0_5
 mov     dl, sil
 add     ecx, edx
 cmp     ecx, edi
 jle     .LBB0_3
.LBB0_5:
 ret
.LBB0_1:
 xor     eax, eax
 ret

```

```asm
 xor     eax, eax
 test    edi, edi
 jle     .LBB1_4
 cmp     edi, 1
 je      .LBB1_3
 lea     eax, [rdi, -, 2]
 lea     ecx, [rdi, -, 3]
 imul    rcx, rax
 shr     rcx
 lea     eax, [rcx, +, 2*rdi]
 add     eax, -3
.LBB1_3:
 add     eax, edi
.LBB1_4:
 ret
```

#### benchmark
在实验下
```
Benchmarking sum/rangeinclusive: Collecting 100 samples in estimated 5.0001 sum/rangeinclusive      time:   [18.604 ns 18.618 ns 18.637 ns]
Found 12 outliers among 100 measurements (12.00%)
  5 (5.00%) high mild
  7 (7.00%) high severe
sum/range               time:   [1.5075 ns 1.5077 ns 1.5079 ns]
Found 4 outliers among 100 measurements (4.00%)
  4 (4.00%) high mild
sum/formula             time:   [1.0059 ns 1.0071 ns 1.0092 ns]
Found 16 outliers among 100 measurements (16.00%)
  3 (3.00%) high mild
  13 (13.00%) high severe

```
我们观察到 
- 直接使用 $n(n+1)/2$的formula函数均值为1.007ns
- 使用闭区间的rangeinclusive函数的均值为18.618ns
- 使用开区间的range函数均值为1.5007ns

## 汇编观察
### 整数除法
我们贴出最简单的1+...+n的通项的代码
```rust
#[inline(never)]
pub fn formula(n: i32)  -> i32 {
    n * (n+1)/2 
}
```

它生成的汇编为
```asm
 lea     ecx, [rdi, +, 1]
 imul    ecx, edi
 mov     eax, ecx
 shr     eax, 31
 add     eax, ecx
 sar     eax
 ret
```
