# mathlib4
Lean4的数学定理库.

## LinearAlgebra
线性代数模块 也涵盖了 抽象线性代数 表示论 代数几何 李群 张量 二次型...

```
LinearAlgebra 
AffineSpace 
Alternating 
Basis
BilinearForm
Charpoly
CliffordAlgebra
BaseChange
Basic
CategoryTheory
Conjugation
Contraction
Equivs
Even
EvenEquiv
Fold
Grading
Inversion
Prod
SpinGroup
Star
Complex
ConvexSpace (file)
Dimension
DirectSum
Dual
Eigenspace
ExteriorAlgebra
ExteriorPower
FiniteDimensional
Finsupp
FreeModule
FreeProduct
GeneralLinearGroup
LinearIndependent
Matrix
Multilinear
PerfectPairing
PiTensorProduct (file)
Projectivization
QuadraticForm
Quotient
RootSystem
SModEq
SesquilinearForm
Span
SymmetricAlgebra
TensorAlgebra
TensorPower
TensorProduct
Transvection (file)
AnnihilatingPolynomial
BilinearMap
Center
Coevaluation
Contraction
Countable
CrossProduct
DFinsupp
Determinant
FiniteSpan
FixedSubmodule
FreeAlgebra
Goursat
InvariantBasisNumber
Isomorphisms
JordanChevalley
Lagrange
LeftExact
LinearDisjoint
LinearPMap
Orientation
PID
Pi
Prod
Projection
Ray
Reflection
Semisimple
SpecialLinearGroup
StdBasis
SymplecticGroup
Trace
UnitaryGroup
Vandermonde
```

| 模块                   | 内容简介                                    |
|------------------------|---------------------------------------------|
| LinearAlgebra          | 线性代数总入口，导入大部分线性代数模块      |
| AffineSpace            | 仿射空间                                    |
| Alternating            | 交替映射（Alternating maps）                |
| Basis                  | 基（Basis）                                 |
| BilinearForm           | 双线性型                                    |
| Charpoly               | 特征多项式                                  |
| CliffordAlgebra        | Clifford 代数                               |
| BaseChange             | 基变换（Base Change）                       |
| Basic                  | 线性代数基础定义（LinearMap、Submodule 等） |
| CategoryTheory         | 线性代数中的范畴论                          |
| Conjugation            | 共轭映射                                    |
| Contraction            | 张量收缩（Contraction）                     |
| Equivs                 | 线性同构（Linear Equiv）                    |
| Even                   | Clifford 代数偶子代数                       |
| EvenEquiv              | Clifford 偶子代数的等价                     |
| Fold                   | Tensor Fold 等折叠操作                      |
| Grading                | 分次结构（Graded Algebra）                  |
| Inversion              | 可逆线性映射相关理论                        |
| Prod                   | 线性空间直积                                |
| SpinGroup              | Spin 群                                     |
| Star                   | 带 * 结构（Star Operation）                 |
| Complex                | 复线性代数相关内容                          |
| ConvexSpace            | 凸空间                                      |
| Dimension              | 维数理论                                    |
| DirectSum              | 直和                                        |
| Dual                   | 对偶空间                                    |
| Eigenspace             | 特征空间                                    |
| ExteriorAlgebra        | 外代数                                      |
| ExteriorPower          | 外幂                                        |
| FiniteDimensional      | 有限维向量空间理论                          |
| Finsupp                | 有限支撑函数（有限线性组合）                |
| FreeModule             | 自由模                                      |
| FreeProduct            | 自由积                                      |
| GeneralLinearGroup     | 一般线性群 GL                               |
| LinearIndependent      | 线性无关                                    |
| Matrix                 | 矩阵理论                                    |
| Multilinear            | 多重线性映射                                |
| PerfectPairing         | 完美配对                                    |
| PiTensorProduct        | Π 型张量积                                 |
| Projectivization       | 射影化                                      |
| QuadraticForm          | 二次型                                      |
| Quotient               | 商空间                                      |
| RootSystem             | 根系                                        |
| SModEq                 | Submodule 等价关系                          |
| SesquilinearForm       | 半双线性型                                  |
| Span                   | 张成空间                                    |
| SymmetricAlgebra       | 对称代数                                    |
| TensorAlgebra          | 张量代数                                    |
| TensorPower            | 张量幂                                      |
| TensorProduct          | 张量积                                      |
| Transvection           | Transvection（初等线性变换）                |
| AnnihilatingPolynomial | 消去多项式                                  |
| BilinearMap            | 双线性映射                                  |
| Center                 | 中心（Center）                              |
| Coevaluation           | Coevaluation（伴随理论）                    |
| Contraction            | 张量收缩                                    |
| Countable              | 可数性相关定理                              |
| CrossProduct           | 三维叉积                                    |
| DFinsupp               | 依赖类型有限支撑函数                        |
| Determinant            | 行列式                                      |
| FiniteSpan             | 有限生成子空间                              |
| FixedSubmodule         | 不动子模                                    |
| FreeAlgebra            | 自由代数                                    |
| Goursat                | Goursat 引理                                |
| InvariantBasisNumber   | 不变基数性质（IBN）                         |
| Isomorphisms           | 各类线性同构                                |
| JordanChevalley        | Jordan–Chevalley 分解                      |
| Lagrange               | 拉格朗日恒等式等                            |
| LeftExact              | 左正合性                                    |
| LinearDisjoint         | 线性无交（Linear Disjointness）             |
| LinearPMap             | 部分线性映射                                |
| Orientation            | 定向（Orientation）                         |
| PID                    | 主理想整环上的线性代数                      |
| Pi                     | Π 类型上的线性结构                         |
| Prod                   | 乘积空间                                    |
| Projection             | 投影                                        |
| Ray                    | 射线                                        |
| Reflection             | 反射变换                                    |
| Semisimple             | 半单模                                      |
| SpecialLinearGroup     | 特殊线性群 SL                               |
| StdBasis               | 标准基                                      |
| SymplecticGroup        | 辛群                                        |
| Trace                  | 迹（Trace）                                 |
| UnitaryGroup           | 酉群                                        |
| Vandermonde            | Vandermonde 矩阵                            |
