# Rust
## 属性
### repr
用于指定数据在内存中的排列方式

1. repr(Rust)
- 默认的表示方式 
- 编译器自由优化布局
- 不保证字段顺序和内存顺序稳定

2. repr(C)
- C语言内存布局
- 字段顺序与声明一致
- 对齐方式遵循C ABI
- 用于FFI

3. repr(transparent)
- 保证单字段类型与其内部非0类型内存布局相同
- 保证只有一个字段是非0大小的

4. repr(u8),repr(i32)...
- 指定enum的判别值类型 覆盖编译器的判别值优化

5. repr(align(n))
- 指定类型的对齐方式
- n是2的幂

6. repr(simd)
- 用于SIMD向量类型

7. repr(packed)
- 以最小可能对齐方式排列
- 清除填充字节

## 技巧
### 未初始化的内存
我们会用到一个类型`core::mem::MabyeUinit`

MabyeUinit
```rust
#[lang = "maybe_uninit"]
#[derive(Copy)]
#[repr(transparent)]
pub union MaybeUninit<T> {
    uninit: (),
    value: ManuallyDrop<T>,
}
```

这里的#[lang = "maybe_uninit"]表明MaybeUninit类型会由编译器做特殊的处理 

transparent告诉编译器MaybeUninit是包装器 它的内存布局与内部非0变量完全相同

故MaybeUninit的内存布局与内部
### union与enum
相较于union,enum会多存储判别值

union保证了0开销
## 库
### ribir
一个gui库

UI直接操作数据，数据的修改直接驱动UI的更新，不需要任何中间层和概念。

#### widget
在ribir中 widget是核心概念.对视图进行描述的基本单元,

在形式上它可以是一个按钮，一个文本框，一个列表，一个对话框，甚至是整个应用界面.

在代码上，它可以是一个函数，一个闭包或者一个数据对象

widget被分为4类:
- 函数 widget
- Compose widget
- Render widget
- ComposeChild widget

##### 函数wdget
接收 `&BuildCtx` 作为参数 并返回Widget的函数或闭包
