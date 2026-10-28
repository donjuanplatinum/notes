# 分析学
## 凹凸性
`Convexity and Concavity`

凹凸性的第一个在分析学的直觉是:

- 凸函数的斜率总体上不减
- 凹函数的斜率总体上不增

严格定义为:

设 $I \subseteq \mathbb{R}$ 是一个**区间**, 函数 $f: I -> \mathbb R$.

对于 **任意的** $x,y \in I$ 与 $\lambda \in [0,1]$ 如果:

$$
f(\lambda x + (1 - \lambda) y) \leq \lambda f(x) + (1 - \lambda) f(y)
$$

那么 f在I上是**凸函数**.

我们观察这个不等式:

- $\lambda x + (1 - \lambda) y$: 这个会遍历x到y之间的**所有点**.
- $\lambda f(x) + (1 - \lambda) f(y)$: (x,f(x))到(y,f(y))的这条直线上的点

其实 $\lambda$ 是对 横坐标 x,y 与 纵坐标 f(x),f(y) 做加权.

这揭示了 (x,f(x)) 到 (y,f(y)) 这条**割线永远比曲线上的值大**. 当然这是连续情况下的.

这个式子完全不要求连续.

### 割线的关系
我们可以得到一个关于**割线**的式子:

取 $x < y < z$

首先: $(z - y) + (y - x) = z - x$, 也就是说我们用y来将 x与z 分成两个区间.

那么

$$
y = \frac{z-y}{z-x} x + \frac{y-x}{z-x} z
$$

我们带入刚才的不等式 就能得到:

$$
$\frac{f(y) - f(x)}{y-x} \leq \frac{f(z) - f(x)}{z-x} \leq \frac{f(z) - f(y)}{ z - y}$
$$

这揭示了 **横坐标从左到右移动, 割线斜率不会变小**.

### 导数的关系
首先我们取 $x < y$ 在凸函数上.

根据割线的不等式:

$$
\frac{f(h) - f(x)}{h-x} \leq \frac{f(y) - f(x)}{y-x} \leq \frac{f(y) - f(h)}{y - h}
$$

因为h是**任意的**,左边与右边分别取h的极限可以得到

$$
f'(x) \leq \frac{f(y) - f(x)}{y-x} \leq f'(y)}
$$

那么可以得到 f'(x) 也就是一阶导是不减的

那么如果一阶导数是不减的, 它的二阶导数是$f''(x) \geq 0$的.

也就是说 凸函数的二阶导 大于等于0
### Jensen不等式
刚才是3个点之间的关系, 但我们可以自然的把这个加权平均给拓展到有限多个点 这就是Jessen不等式.

$$
f(\sum_{i=1}^{n} \lambda_i x_i) \leq \sum_{i=1}^{n} \lambda_i f(x_i)
$$

其中 $\sum_{i=1}^n \lambda_i = 1$
### 重要结论


1. 凸性定义: $f(\lambda x + (1 - \lambda) y) \leq \lambda f(x) + (1 - \lambda) f(y)$

2. 割线的不等式: $\frac{f(y) - f(x)}{y-x} \leq \frac{f(z) - f(x)}{z-x} \leq \frac{f(z) - f(y)}{ z - y}$

3. 若函数是凸的 那么它的一阶导数不减, 二阶导数 $\geq 0$

4. Jessen不等式
