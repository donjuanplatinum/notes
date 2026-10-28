# 函数
## 特殊函数
特殊函数是具有特定性质的函数. 它们的用途挺广的 和微分方程 各种分析学 概率论关系很大.
### Gamma 
Gamma是 **第二类Euler积分**, 是对**阶乘的推广**.

根据Bohr-Mollerup定理:

1. 

$$
\boxed{
\Gamma(x+1) = x \Gamma(x)
}
$$

2. 初始条件: $\Gamma(1) = 1$

3. 最重要的是 它具有 **对数凸性** 即 $ln \Gamma(x)$是凸的

那么**唯一**满足这些条件的函数就是Gamma函数.

Gamma函数的定义是

$$
\Gamma(z) = \int_{0}^{\infty} e^{-t} t^{z-1} dt
$$



#### 递推关系与阶乘对应
最基础的递推关系为**阶乘**的递推关系.

我们对$\Gamma(z)$ 使用对t的**分部积分**.

$$
\Gamma(z) = \int_{0}^{\infty} e^{-t} t^{z-1} dt \\
 =  [-e^{-t} t^{z-1}]^{\infty}_0 - \int_{0}^{\infty} - e^{-t} (z-1) t^{z-2} dt \
$$

左边的极限等于0 右边是 $(z-1) \Gamma(z-1)$

所以有

$$
\boxed{
\Gamma(z) = (z-1) \Gamma(z-1)
}
$$

我们再来看 **初始条件**, $ G(1) = \int_{0}^{\infty} e^{-t} dt = 1$

那么, $G(2) =  1 * G(1) = 1$, $G(3) = 2$, $G(4) = 6$.

则

$$
\boxed{
\Gamma(z) = (z-1)!
}
$$
#### 对数凸性与Digamma函数
对数凸性是Gamma函数区别于其他的 阶乘函数的沿拓 的最重要的性质, 它是**
唯一**具有 **对数凸性** 的阶乘沿拓.

我们对$\Gamma(z)$取对数 得到$ln\Gamma(z)$.

为了证明严格凸性 我们先求一次导.

$$
\frac{d}{dx} ln \Gamma(z) = \frac{\Gamma'(z)}{\Gamma(z)}
$$

这个函数很特殊 我们定义它叫做: Digamma函数 即 $\psi(z)$.

$$
\boxed{
\psi(z) = \frac{\Gamma'(z)}{\Gamma(z)}
}
$$

我们求第二次导.

$$
\frac{d}{dx} \frac{\Gamma'(z)}{\Gamma(z)} = \\
\frac{\Gamma''(z) \Gamma(z) - [\Gamma'(x)]^2}{\Gamma^2(x)}

$$

首先, $\Gamma^2(x)$ 肯定是大于0的 那么我们分析 $\Gamma''(z) \Gamma(z) - [\Gamma'(x)]^2$.

现在我们来回忆线性代数章节中的 **内积** 与 **Cauchy-Schwarz**不等式 或者微积分学中的这个不等式.

根据

$$
\boxed{
\| u\| \| v \| \geq | \langle u,v \rangle |
}
$$

我们定义内积为 $L^2$(不含复数) 内积: 

$$
\langle f,g \rangle = \int f g
$$

那么 **范数**为:

$$
\| u \| = \sqrt{ \langle u , u \rangle } = \sqrt{\int u^2}
$$

那么有

$$
\boxed{
\int f^2 * \int g^2 \geq (\int f g)^2 
}
$$

我们将它应用于 $\Gamma''(z) \Gamma(z) - [\Gamma'(x)]^2$

那么自然的有:

$$
\boxed{
\int \Gamma(x) * \int \Gamma''(x) = \\
\int (e^{-t} t^{x-1}) * \int (e^{-t} t^{x-1} (lnt)^2) \geq \\
(\int e^{-t} t^{x-1} e^{-t} t^{x-1} (lnt)^2 ) = \Gamma'(x)^2
}
$$

所以 $ln \Gamma(x)$的二阶导函数大于等于0 所以它具有对数凸性.
#### 对数凸性的唯一性与Euler极限
现在我们需要证明 满足对数凸性的唯一阶乘沿拖是 Gamma函数.

首先 我们从 **阶乘** 开始:

$$
f(z) = (z-1) f(z-1)
$$

我们取对数:

$$
ln f(z) = ln(z-1) + ln f(z - 1)
$$

其中 我们令$g(z) = ln f(z)$

由于有

$$
g(z) = ln(z-1) + g(z-1)
$$

我们把乘法的递推变成了加法的递推.

由于 **对数凸性**, 我们对它使用 **割线的不等式** 参考分析学中的割线不等式.

我们取 $x \in (0,1)$, 然后取 `n+x`, `n+1` ,`n+2`三个点.

由于g是凸的 那么g满足

$$
\frac{g(n+1) - g(n+x)}{1-x} \leq \frac{g(n+2) - g(n+1)}{1}
$$

即

$$
g(n+1) - g(n+x) \leq (1-x) (g(n+2) - g(n+1))
$$

我们带入递推 可以把 g(n+2)与g(n+1)化简.

$$
\frac{g(n+1) - g(n+x)}{1-x} \leq ln(n+1) \\
\frac{g(n+x)} \geq g(n+1) + (x-1) ln(n+1)
$$

我们把f恢复

$$
f(n+x) \geq (n+1)^{x-1} f(n+1)
$$

我们展开f(n+1)

$$
f(n+x) \geq (n+1)^{x-1} n! f(1)
$$

然后我们获得f(n+x)的上界, 因为g是凸的. 我们应用凸性不等式

我们取n 与 n+1两个点. n+x被夹在中间 所以在它们的连线下.

$$
g(n+x) & \leq (1-x)g(n) + xg(n+1) \\
g(n+x) & \leq (1-x)g(n) + x(g(n) + lnn) \\
g(n+x) & \leq g(n) + x lnn \\
ln f(n+x) & \leq ln f(n) n^x
$$

那么有

$$
f(n+x) \leq n^x f(n) = n^x (n-1)!
$$

那么我们看上界与下界

$$
(n+1)^{x-1} n! \leq f(n+x) \leq n^x (n-1)!
$$

我们看看两边的极限:

$$
\lim_{n->\infty} \frac{(n+1)^{x-1} n!}{n^x (n-1)!} = \frac{(n+1)^{x-1} n!}{n^{x-1} n!} = \frac{(n+1)^{x-1}}{n^(x-1)} = 1
$$

所以两边实际上是一个极限.

我们将f(n+x)展开为f(x)后这个极限叫做Euler极限

$$
f(x) = \lim_{x->\infty} \frac{n^x (n-1)!}{(x+n-1) ... (x+1) x}
$$
#### 重要的等式

1. 积分定义: $\Gamma(z) = \int_{0}^{\infty} e^{-t} t^{z-1} dt$

2. 递推: $\Gamma(z) = (z-1) \Gamma(z-1)$

3. 与阶乘的关系: $\Gamma(z) = (z-1)!$

4. Digamma函数: $\psi(z) = \frac{\Gamma'(z)}{\Gamma(z)}$

5. Euler极限: $\Gamma(z) = \lim_{n->\infty} \frac{(n-1)! n^x}{x(x+1)...(x+n-1)}$
