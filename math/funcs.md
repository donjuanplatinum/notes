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
\Gamma(z) = & \int_{0}^{\infty} e^{-t} t^{z-1} dt \
 = & [-e^{-t} t^{z-1}]^{\infty}_0 - \int_{0}^{\infty} - e^{-t} (z-1) t^{z-2} dt \
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

\boxed{
\psi(z) = \frac{\Gamma'(z)}{\Gamma(z)}
}

我们求第二次导.

$$
\frac{d}{dx} \frac{\Gamma'(z)}{\Gamma(z)} = \
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
\int \Gamma(x)^2 * \int \Gamma''(x)^2 = \
\int (e^{-t} t^{x-1})^2 * \int (e^{-t} t^{x-1} (lnt)^2)^2 \geq \
(\int e^{-t} t^{x-1} e^{-t} t^{x-1} (lnt)^2 )^2 = \Gamma'(x)
}
$$

所以 $ln \Gamma(x)$的二阶导函数大于等于0 所以它具有对数凸性.
