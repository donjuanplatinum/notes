# 线性代数
## SVD
奇异值分解

对于任意矩阵 $A \in \mathbb{R}^{m \times n}$

都存在分解

$$
A = U \Sigma V^T
$$

其中
- $U \in \mathbb{R}^{m \times m}$ :左奇异向量,正交矩阵$(U^T U = I)$
- $\Sigma \in \mathbb{R}^{m \times n}$ : 奇异值矩阵 对角线非负
- $V \in \mathbb{R}^{n \times n}$ :右奇异向量 正交矩阵


SVD是一个三步的线性变换

$$
x \xrightarrow{V^\top} \text{旋转} \xrightarrow{\Sigma} \text{拉伸} \xrightarrow{U} \text{再旋转}
$$

- $V^T$: 把输入坐标系旋转到主方向
- $\Sigma$: 沿正交方向按奇异值缩放
- $U$: 映射到输出空间

### 低秩近似
只保留矩阵中最重要的几个方向 其他方向当成噪声掩盖掉

SVD方法是**最优**的低秩近似(Eckart-Young定理): 在所有$rank \leq k$的矩阵中 截断SVD给出的$A_k$ 是误差(Frobenius范数误差)最小的


## Frobenius范数
对于矩阵$A = (a_{ij})$

$$
\| A\|_F = \sqrt{\sum_{i,j}a_{ij}^2}
$$

即所有元素的平方和
