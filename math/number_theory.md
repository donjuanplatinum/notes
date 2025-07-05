# 数论
## 整数
- 良序性质: 每个非空的正整数集合都有一个最小元
### 整数集公理
整数集 $ \mathbb{z} = \{...,-1,0,1,2,..\} $

- 封闭性: $ a, b \in \mathbb{z} ,则 a + b \in \mathbb{z} , a \cdot b \in \mathbb{z} $
- 交换律: $ 对任意a, b \in \mathbb{z}, a + b = b + a, a \cdot b = b \cdot a $
- 结合律: $ 对任意a, b, c \in  \mathbb{z}, (a+b)+c = a+(b+c), (ab)c = a(bc)$
- 分配率: $ 对任意a, b, c \in \mathbb{z}, (a+b)c = ac +bc $
- 单位元: $ 对任意a \in \mathbb{z}, a + 0 =a, a \cdot 1 = a$

- 加法逆元: $\forall a \in \mathbb{z}, 方程 a + x = 0 有整数解x , 我们称x 为 a的加法逆元, 记作 -a.另外有 b - a 表示 b + (-a)$

- 消去律: $ 若a ,b, c \in \mathbb{z}, 满足 ac = bc 且 c \neq 0 , 则a = b $


证明: $ 0 \cdot a = 0$


$\because 0是 单位元, 我们有 0+0 = 0 .两边同乘a有 (0+0) \cdot a = 0 \cdot a. $

$根据分配率 (0+0) \cdot a = 0 \cdot a + 0 \cdot a = 0 \cdot a. $

$两边同时减去 0 \cdot a 左边有 0 \cdot a + (0 \cdot a - 0 \cdot a) = 0 \cdot a + 0  = 0 \cdot a 右边有 0 \cdot a - 0 \cdot a = 0$

$ 则 0 \cdot a = 0 $


#### 整数集次序
$设 a,b \in \mathbb{z} , 若 b - a 是正整数, 则称 a < b$

整数集次序基本性质
- 正整数的封闭性: 若 a 和 b是正整数 则a + b 和 $a \cdot b$ 一定是正整数
- 三分律: 任意整数 a,  a >0 , a =0 , a < 0 有且仅有一条成立

#### 整数集良序性
正整数集的任意非空子集中均含有最小元素

### 最大整数函数(高斯函数)
$ [x] \leq x < [x] + 1 $

### Dirichlet鸽笼原理(抽屉原理)
k+1个或更多物体放入k个盒子 至少有一个盒子会有2个或更多物体

证明: 假设所有盒子的物体都<2 (也就是仅一个), 那么物体总数为k < k+1 即 $\leq$ k 与 总数$\geq k+1$  矛盾. 故至少一个盒子中的物体数 $\geq$ 2
### Diophantus(丢番图逼近)
Diophantus逼近研究的问题类型是: 证明是否一个实数的前k个倍数中的某一个一定更接近某个整数
