# 技巧
## 宏
### 类型多定义
我们在**定义类型**的时候 为了给它**各种泛型的实现** 或者**各种引用的实现**的时候 可以使用**过程宏**

比如 类型A 实现了 `A Add A`, 我们可能还想实现 `A Add &A`... 就可以这样实现

```rust
/// impl<'a,'b,T: Clone + NumOps> Method<&'a Complex<T>> for &'b Complex<T>
macro_rules! impl_ref_ref {
    (impl $imp:ident, $method:ident) => {
        impl<'a, 'b, T: Clone + NumOps> $imp<&'a Complex<T>> for &'b Complex<T> {
            type Output = Complex<T>;

            #[inline]
            fn $method(self, other: &'a Complex<T>) -> Self::Output {
                self.clone().$method(other.clone())
            }
        }
    };
}

/// impl<'a,T: Clone + NumOps>  Complex<T> for &'a Complex<T>
macro_rules! impl_val_ref {
    (impl $imp:ident, $method:ident) => {
        impl<'a, T: Clone + NumOps> $imp<&'a Complex<T>> for Complex<T> {
            type Output = Complex<T>;

            #[inline]
            fn $method(self, other: &'a Complex<T>) -> Self::Output {
                self.$method(other.clone())
            }
        }
    };
}

/// impl<'a,T: Clone + NumOps> &'a Complex<T> for  Complex<T>
macro_rules! impl_ref_val {
    (impl $imp:ident, $method:ident) => {
        impl<'a, T: Clone + NumOps> $imp<Complex<T>> for &'a Complex<T> {
            type Output = Complex<T>;

            #[inline]
            fn $method(self, other: Complex<T>) -> Self::Output {
                self.clone().$method(other)
            }
        }
    };
}

macro_rules! impl_all {
    (impl $imp:ident ,$method: ident) => {
        impl_ref_val!(impl $imp, $method);
        impl_ref_ref!(impl $imp, $method);
        impl_val_ref!(impl $imp, $method);
    };
}

```


## 类型
### 泛型限制与上下界实现
可以为类型的集合定义泛型来约束

```rust
pub trait NumOps<Rhs = Self, Output = Self>:
    Add<Rhs, Output = Output>
    + Sub<Rhs, Output = Output>
    + Mul<Rhs, Output = Output>
    + Div<Rhs, Output = Output>
    + Rem<Rhs, Output = Output>
{
}

impl<T, Rhs, Output> NumOps<Rhs, Output> for T where
    T: Add<Rhs, Output = Output>
        + Sub<Rhs, Output = Output>
        + Mul<Rhs, Output = Output>
        + Div<Rhs, Output = Output>
        + Rem<Rhs, Output = Output>
{
}
pub trait NumCmp<Rhs = Self>: PartialEq<Rhs> + PartialOrd<Rhs> + Eq + Ord {}
impl<T> NumCmp for T where T: PartialEq + PartialOrd + Eq + Ord {}
```

其中 这两行是精髓 一揽子实现
```rust
pub trait NumCmp<Rhs = Self>: PartialEq<Rhs> + PartialOrd<Rhs> + Eq + Ord {}
impl<T> NumCmp for T where T: PartialEq + PartialOrd + Eq + Ord {}
```
### 约束究竟放在哪里
[Question about types and generics](https://users.rust-lang.org/t/question-about-types-and-generics/137599/2)

在类型的定义上 一般可以采用标准库的思想: `在类型定义时不去绑定 而在方法时进行绑定`

比如下面这段代码 就是在`Complex<T>`定义时不限制T 而是在impl时限制T为`FloatOps+NumOps`
```rust
pub struct Complex<T> {
	re: T,
	im: T,
}

impl<T: FloatOps + NumOps> Complex<T> {
    pub fn from_polar(r: T,theta: T) -> Complex<T> {
		Complex { 
		re: r.clone() * theta.clone().cos(),
		im: r * theta.sin() }
    }
}
```

这里的原因可以引用[quinedot](https://users.rust-lang.org/t/question-about-types-and-generics/137599/8)的回答

以及这个[PR](https://github.com/rust-lang/rust/pull/149408)
### 生命周期型变
[LifeTime](https://users.rust-lang.org/t/untangling-my-lifetime-and-borrow-rules-mental-model/137545/6?u=donjuanplatinum)

| 类型      | 在`'a`上的型变 | 在`T`上的型变 |
|-----------|----------------|---------------|
| &'a T     | 协变           | 协变          |
| &'a mut T | 协变           | 不变          |
| *const T  |                | 协变          |
| *mut T    |                |               |

考虑以下的代码 这一段是不能通过编译的 这是因为`&'a T`对于`'a` 是**协变**的

Rust的推理逻辑为: 

make_handle(&mut od) 这里拿走了od的所有权 返回一个`Handle<'a>` 而Handle<'a>关于<'a>协变

所以编译器必须假设: 这个Handle可能在逻辑上依赖 `&'a mut od`

```rust
use std::marker::PhantomData;
 
struct Handle<'a> {
    _fake: PhantomData<&'a ()>,
}
 
fn make_handle<'a>(_: &'a mut [u32]) -> Handle<'a> {
    Handle { _fake: PhantomData }
}
 
fn main() {
    let mut od = [0u32; 10];
    let handle_1 = make_handle(&mut od);
    let handle_2 = make_handle(&mut od); // FAIL: cannot borrow `od` as mutable again
    drop(handle_1);
}
```

而下面的代码可以通过编译 因为函数参数`fn(&'a T)`对生命周期是 `逆变`的 也就是说 编译器可以假设Handle并不依赖于`fn(&'a T)` 

```rust
use std::marker::PhantomData;
 
struct Handle<'a> {
    _fake: PhantomData<fn(&'a ())>,
}
 
fn make_handle<'a>(_: &'a mut [u32]) -> Handle<'a> {
    Handle { _fake: PhantomData }
}
 
fn main() {
    let mut od = [0u32; 10];
    let handle_1 = make_handle(&mut od);
    let handle_2 = make_handle(&mut od); //Works because `Handle` is contravariant over its lifetime
    drop(handle_1);
}
```
## 编译优化
### 何时使用inline
[In what circumstances should a function be inline?](https://users.rust-lang.org/t/in-what-circumstances-should-a-function-be-inline/137636/4?u=donjuanplatinum)

Rust的内联依靠4个属性来标记

- 无: 编译器自行决定
- `#[inline]`: 该函数会内联
- `#[inline(always)]`: 该函数强烈建议内联
- `#[inline(never)]`: 强烈不建议内联

>递归函数不能内联
>内联是非传递性的

最基本的适合内联的情况是:
1. 这个函数很小

```rust
fn a(m: usize,n: usize) -> bool{
	m < n
}
```

2. 这个函数的调用点很少 或者在一个调用点调用的多

```rust
fn a(){}
for i in 0..1_000_000 {
	a();
}
```

内联的好处

1. 减少函数调用带来的开销
2. 一旦内联 调用者和被调用者可以作为一个整体代码进行优化 

>如果一个函数在内联后没有任何优化的潜力，那么内联可能几乎没有任何好处，甚至由于代码大小增加（增加指令缓存压力）而导致性能更差。
### 区间到底使用什么
## 迭代器与方法
### then系列
当第一关键字相等时，再比较第二关键字。
### for each
可以直接用for each简化初始化.

原来是

```rust
for i in 0..len {
	dp[i][i] = 1;
}
```

简化后
```rust
(0..len).for_each(|i| dp[i][i] = 1);
```


