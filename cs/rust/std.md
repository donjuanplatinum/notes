# Std
Rust的标准库

Rust的标准库分为几个部分 它们是自底向上的依赖关系

- 原始数据类型: 基本数据类型 array, f32 ,i32 ...
- core: Rust最基本的环境 不依赖系统 文件系统 内存分配,也就是no_std环境. 用于嵌入式 内核开发
- alloc: 堆分配支持 适用于有堆但无std的环境
- std: 完整的标准库
- proc_macro: 标准库的宏库
- test: 标准库的测试宏与框架


## core
Rust核心库是Rust标准库的无依赖基础 它没有链接到上游库 没有系统库 也没有 libc
### primitive types
原始数据类型 不过多介绍

### iter
迭代器

*迭代器是指实现了Iterator trait的类型*

#### Iterator
迭代器的Trait
```rust
pub trait Iterator {
	type Item;
}
```

其中`Item`是迭代器吐出的元素的类型

必须方法:
- next
推动迭代器 并返回下一个值. 其中,迭代完成返回`Option::None`.

不同的实现可能会在返回None后 继续调用next 会返回Some
```rust
fn next(&mut self) -> Option<Self::Item>
```

##### fold
累加器

```rust
fn fold<B,F>(self,init: B,f: F) -> B 
	where
	Self: Sized,
	F: FnMut(B,Self::Item) -> B,
```

init为初始值 f为累加的闭包
### ops
可重载运算符

#### Fn/FnMut/FnOnce
闭包实现的Trait

1. Fn: 接收`&self` `Fn`的实例可以在**不改变状态**的情况下**重复调用**。
```rust
pub trait Fn<Args: Tuple>: FnMut<Args> {
    // Required method
    extern "rust-call" fn call(&self, args: Args) -> Self::Output;
}

```

2. FnOnce: 接收`self` 调用会消耗自身 只能调用一次
```rust
pub trait FnOnce<Args: Tuple> {
    type Output;

    // Required method
    extern "rust-call" fn call_once(self, args: Args) -> Self::Output;
}
```

3. FnMut: 接收`&mut self` 可以在**改变状态**的情况下**重复调用**
```rust
pub trait FnMut<Args: Tuple>: FnOnce<Args> {
    // Required method
    extern "rust-call" fn call_mut(
        &mut self,
        args: Args
    ) -> Self::Output;
}
```
`
### sync
线程同步原语
#### atomic
原子类型 提供线程之间的原始共享内存通信

##### Ordering
原子类型的内存排序严格程度

```rust
pub enum Ordering {
	Relaxed,
	Release,
	Acquire,
	AcqRel,
	SeqCst,
}
```

- `Relaxed`: 没有排序约束 只有原子操作

即: 

1. 对同一个原子变量 所有线程观察到的值的**变化顺序**一致. 若变量从0->1->2 所有线程看到的都是0->1->2

2. 指令本身具有原子性 在`fetch_add`之类的指令执行时 不会出现执行一半的情况

- `Release`/`Acquire`: 这对组合建立前序与后序的关系

Acquire保证此操作之后的读取与写入不会被排到此操作前

Release保证此操作之前的读取与写入不会被排到此操作后

- `AcqRel`: 等于Relase+Acquire

- `SeqCst`: 最严格的约束 在AcqRel的基础上要求 所有线程看到的SeqCst的操作顺序必须一致
