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

#### Traits
##### Iterator
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

