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

#### 数字类型

方法
- `trailing_zeros`: 返回`尾随的0` 即从右往左的第一个1右边有几个0.
- `leading_zeros`: 返回`前导0` 即从左往右的第一个1右边有几个0.
#### bool

- `then(self, f: F)`: 如果是true 则返回f 否则None
- `then_some(self, t: T)`: 如果是true 则返回T 否则None
#### pointer
裸指针 `*const T` 与 `*mut T`.

注意, `*ptr = data`操作会在原来地址上的值上调用`drop()` 所以如果原来的内存没有**初始化**的化 这是个未定义行为. 这个时候我们可以使用`core::ptr::write()` 这个方法不会调用原来地址的`drop()`

1. 创建裸指针的方法:

- 对于栈上的 可以从 **引用转换而来**.

```rust
let a: i32 = 10;
let ptr: *const i32 = &a;
```

- 对于堆上的 可以 **解引用** `Box`. 但是注意 这并不会获得Box在堆上的所有权, Box的所有权仍然会在超出作用域drop, 这个时候用ptr会未定义行为.
```rust
let a: Box<i32> = Box::new(10);
let ptr: *const i32 = &*a;
```

2. 消费box

box的`into_raw()`函数会消费自己 并返回裸指针. 但是注意: **那个数据还在堆上 我们需要手动管理它的所有权**.

```rust
let a: Box<i32> = Box::new(1);
let a_ptr: *mut i32 = Box::into_raw(a);

unsafe {
	drop(Box::from_raw(a));
}
```

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

- 举例: 0..101的和

```rust
let sum = (0..101).into_iter().fold(0,|acc,x| acc + x);
```
##### filter
过滤器 , 将满足条件的元素返回成一个迭代器.

```rust
fn filter<P>(self,predicate: P) -> Filter<Self,P> 
where
	self: Sized,
	P: FnMut(&self::Item) -> bool,
```

举例: 0..101的偶数的和

```rust
let sum = (0..101).into_iter().filter(|i| i % 2 == 0).fold(0,|acc,x| acc + x);
```
##### map
给迭代器的每个元素应用一个操作 然后返回作用后的迭代器.

```rust
fn map<B,F>(self, f:F) -> Map<Self,F>
where
	Self: Sized,
	F: FnMut(Self::Item) -> B
```

举例: 将(0..101)的每个数对9取余.

```rust
(0..101).into_iter().map(|i| i % 9)
```
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


### cmp
比较模块
#### Ordering
两个值比较的结果

- `then(self, other: Ordering) -> Ordering`: 链接两个排序.若self不是`Equal` 则返回self. 否则返回`other`

### ptr
裸指针

#### NonNull
非0且协变的`*mut T`. 

由于`NonNull`是**covariant**的， 所以如果我们自己抽象的类型需要**invariant** 那么我们需要`PhantomData`调整variance.

方法
- `dangling()`: 创建悬垂指针
- `new_unchecked(ptr: *mut T) -> Self`: 从`*mut T`创建`NonNull<T>`, 这里假定ptr**一定非空**.
- `new(ptr: *mut T) -> Option<Self>`: 与`new_unchecked`的区别在于 会先检查是否是空
- `as_ptr(self) -> *mut T`: 获取底层 `*mut`指针


## std
rust的全功能**标准库**. 包括了 `Vec<T>`, 操作系统I/O, 多线程等
### boxed
在rust里 ,`Box<T>`的使命类似于C的`malloc`,`free` 即在堆上分配与管理对象.

而`Box<T>`具有堆上对象的所有权. 它是一个 **智能指针**.


### collections
数据结构.

#### LinkedList
双向链表

```rust
pub struct LinkedList<
    T,
    #[unstable(feature = "allocator_api", issue = "32838")] A: Allocator = Global,
> {
    head: Option<NonNull<Node<T>>>,
    tail: Option<NonNull<Node<T>>>,
    len: usize,
    alloc: A,
    marker: PhantomData<Box<Node<T>, A>>,
}

struct Node<T> {
    next: Option<NonNull<Node<T>>>,
    prev: Option<NonNull<Node<T>>>,
    element: T,
}
```


- `new()`: 创建空的链表
- `append(&mut self,other: &mut LinkedList<T,Global>)`: 将另一个链表`other`插入到self的后面
- `push_back(&mut self,elt: T)`: 将元素追加到尾部
- `push_front(&mut self,elt: T)`: 将元素追加到前面
- `pop_front(&mut self,elt: T)`: 将最前面元素弹出
- `pop_back(&mut self,elt: T)`: 将最后面元素弹出

