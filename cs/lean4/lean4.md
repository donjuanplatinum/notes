# Lean4
Lean4是一个完备的**编程语言** 侧重于**数学定理证明**

Lean是一种严格的**纯函数式语言**

## 工具链
gentoo安装
```bash
emege -v sci-mathematics/lean
```

- lake: 库依赖管理器 相当于Rust的Cargo
- lean: 编译器

## 交互
Lean4有很多交互式函数

- `#eval`: 执行后面的表达式
- `#check`: 类型检查
## 类型
和Rust一样 使用`:`作为类型标注 但是注意 
>在Lean中 `:`的优先级很低 所以必须这样写

```lean
#eval (1 : Nat) - (2 : Nat)
```

类型定义

- 结构体
```lean
structure Point where 
	x: Float
	y: Float
	z: Float
```

这里有一个语法糖

如果需要修改结构中的少量值 可以这么写
```lean
def zeroX (p : Point) :Point :=
	{p with x := 0}
```

也就是说 需要修改的值写在关键字`with`后面 

- 闭包与lambda

闭包的形式为 
```lean
f: Float → Float
```

lambda的形式为

```lean
(fun arg1 => expr)
```

举个例子
```lean
def _point (p: Point) (f: Float → Float) : Point :=
    {x := f p.x,y := f p.y}

#eval _point b (fun a => a + 0.1)
```

- 归纳数据类型

可以通过**数学归纳法**来证明它们的陈述的类型

Bool和Nat是经典的归纳数据类型

```lean
inductive Bool where
	| false : Bool
	| true : Bool
	
inductive Nat where
	| zero : Nat
	| succ (n : Nat) : Nat
```
其中 succ代表后继 
>任何Nat都可以表示为0的若干个后继

- 模式匹配
```lean
match Nat.zero with
	| Nat.zero => true
	| Nat.succ k => false
```
### Rat
有理数类型 写为ℚ

实现为一对整数的分数 其中: 分母为正数,且分子与分母**互质**

```lean
structure Rat where
  -- 通过各个组件构造一个有理数。 我们将构造函数重命名为 mk'，以避免与“智能构造函数”发生冲突
  -- 建议使用封装后的智能构造函数而不是mk'
  mk' :: -- 原始的构造函数
  num : Int -- 分子
  den : Nat := 1 -- 分母
  den_nz : den ≠ 0 := by decide -- 属性: 分母不为0
  reduced : num.natAbs.Coprime den := by decide -- 属性: 分子分母必须互质
  deriving DecidableEq, Hashable -- 类似Rust的#[derive]
```
## 函数与定义
`def`关键字在Lean中进行定义.

- 定义名称

```lean
def hello := "Hello"
-- 标注类型
def lean: String := "Lean"
```

- 定义函数

```lean
def add1 (n: Nat): Nat := n+1
```

## 结构体
定义结构体在Lean4中引入新的类型. 这种类型无法简化为其他任何类型.

```lean
structure Point where
  x : Nat
  y : Nat
  
def origin: Point := {x := 0 , y := 0 }  
```
## 关键字
- `let`: 赋值
- `have`: 提出一个假设或中间证明
## 函数
在rust中函数定义为
```rust
fn a() -> String {
	"ok".to_string()
}
fn b(arg1: i32,arg2: i32) -> i32 {
	arg1 + arg2 + 1
}
```

在lean中
```lean
def a : String := "ok"
def b(arg1: Int)(arg2: Int): Int := arg1 + arg2 + 1
```
## 定理与命题
在Lean中 **命题是类型 证明是值**


## Tactics
Tactics在Lean中用于处理证明任务 通过tactics来控制证明过程

- `rfl`: 证明两边**定义相等** 注意是定义相等
```lean
example : 1 + 1 = 2 := by
	rfl
```

### Built-in
Lean4的内置Tatics
#### 逻辑操作
- `intro`: 引入一个假设或目标 

假设命题成立为h
```lean
theorem two_not_square_rat : ¬ ∃ q : ℚ, q^2 = 2 := by
  intro h
```

- `cases`: 对命题进行拆解 分类讨论
- `induction`: 递归证明 比如归纳法
```lean
induction n with d hd
rw [add_zero 0]
rfl
rw [add_succ 0 d]
rw [hd]
rfl
```

其中 n为要归纳的变量 d为归纳假设的变量名 hd为归纳假设的名称

hd相当于我们在数学归纳法中 假设的n=k时成立时的式子

#### 等式化简/转化
- `rw`: 带入
- `refl`: 证明自反性
### Mathlib
Mathlib库的tatics

#### 逻辑操作
- `rcases`: 递归cases

把h拆开为 q: 若命题成立 q^2=2的q, hq: 证明q^2 = 2的证据
```lean
theorem two_not_square_rat : ¬ ∃ q : ℚ, q^2 = 2 := by
  intro h
  rcases h with ⟨q, hq⟩
```
#### 等式化简/转化

- `norm_cast`: 类型转换
