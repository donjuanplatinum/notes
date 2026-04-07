# 宏
## 宏基础
Rust的Macro主要分为 
- 声明宏: `macro_rules!`

Rust最基本的宏 用于模式匹配替换

- 过程宏: `#[proc_macro]`

通过函数生成函数 可以理解为**泛函**

### 声明宏
声明宏通过进行**模式匹配** 然后进行**填充模板**

```rust
macro_rules! greet {
	() => {
		println!("Hello World!");
	};
	
	($name:expr) => {
		println!("Hello,{}!",$name);
	};
	($greeting:expr,$name:expr) => {
		println!("{} {}!",$greeting,$name);
	};
}

fn main() {
	greet!();
	greet!("World");
	greet!("Morning","World");
}
```

其中
- `$name:expr`: $name是宏变量 expr是模式类型

#### 重复模式
| 模式       | 含义                 |
|------------|----------------------|
| `$(...)*`  | 匹配>=0次 没有分隔符 |
| `$(...),*` | 匹配>=0次 以逗号分隔 |
| `$(...);*` | 匹配>=0次 以分号分隔 |
| `$(...)+`  | 匹配>=1次 没有分隔符 |
| `$(...),+` | 匹配>=1次 以逗号分隔 |
| `$(...);+` | 匹配>=1次 以分号分隔 |
| `$(...)?`  | 匹配0/1次 没有分隔符 |

#### 模式类型
| 模式类型 | 含义       | 示例                                                        |
|----------|------------|-------------------------------------------------------------|
| expr     | 表达式     | `2 + 2`, `"ok"`, `a.b()`, `vec![1,2]`                       |
| ty       | 类型       | `String`, `Vec<i32>`, `dyn Read + Send`, `&mut T`           |
| path     | 路径       | `fern::Dispatch`, `::std::sync::mpsc`, `self::module::func` |
| pat      | 模式       | `_`, `Some(ref x)`, `(a, b)`, `[x, ..]`                     |
| item     | 语法项     | `fn foo() {}`, `struct S {}`, `mod m {}`, `impl T {}`       |
| stmt     | 语句       | `let x = 1;`, `x += 1;`, `for i in 0..5 {}`                 |
| block    | 块         | `{ let x = 1; x + 2 }`                                      |
| macro    | 宏调用     | `println!("hi")`, `vec![1,2,3]`                             |
| tt       | Token Tree | `2`, `+`, `foo`, `{}`, `;`                                  |
| ident    | 标识符     | `x`, `my_var`, `Foo`                                        |
| literal  | 字面量     | `42`, `"hello"`, `3.14`, `true`                             |
| vis      | 可见性修饰 | `pub`, `pub(crate)`, `pub(super)`                           |
