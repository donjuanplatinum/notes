# 算法
## 基本算法
### 旋转算法
旋转算法主要有这几种

- 手摇(三次)旋转
- 临时空间
- 循环置换(juggling/gcd)
- 块交换

我们来看Rust标准库的实现
```rust
type BufType = [usize; 32];
#[inline]
pub(super) const unsafe fn ptr_rotate<T>(left: usize, mid: *mut T, right: usize) {
	// 边界条件处理
    if T::IS_ZST {
        return;
    }
    if (left == 0) || (right == 0) {
        return;
    }
	
    if !cfg!(feature = "optimize_for_size")
        && core::cmp::min(left, right) <= size_of::<BufType>() / size_of::<T>()
    {
		// 当有left或right有一个块小到足以装进BufType规定的缓冲区时 使用memmove
        unsafe { ptr_rotate_memmove(left, mid, right) };
    } else if !cfg!(feature = "optimize_for_size")
		// 当左和右一共<24时 也就是旋转的总规模很小时 使用GCD算法
        && ((left + right < 24) || (size_of::<T>() > size_of::<[usize; 4]>()))
    {
	
        unsafe { ptr_rotate_gcd(left, mid, right) }
    } else {
        unsafe { ptr_rotate_swap(left, mid, right) }
    }
}
```

### 贪心算法
每一步只做当前看起来最好的选择（局部最优），并期望这些局部最优能累积成全局最优。

贪心算法通常有两个特质:

1. 贪心选择性质: 全局最优可以通过局部最优选择来达到.

2. 最优子结构: 一个问题的最优解包含其字问题的最优解.

接下来我会给出各种贪心算法的证明
#### 交换论证
我们需要证明 贪心解不差于最优解.

假设存在一个最优解 每一步的选择是

$$
(o_1,o_2,...,o_m)
$$

而贪心解每一步的选择是 

$$
(g_1,g_2,..,g_m)
$$

那么我们选择其中一步 i

- 若 $o_i = g_i$ 则两者一致 我们递归或者归纳的处理剩下的

- 若 $o_i != g_i$ 那我们用$g_i$ 替换 $o_i$ 证明替换后的 $o_1,o_2,...,g_i,...,o_m$ 不差于原来的
#### 区间覆盖
1. 对于任意最短路径 如果第一步没有走到当前能到达的最远点 那么把第一步替换成最远点 不会增加后续步数
### DP动态规划
动态规划的本质只有一件事

> 把重复计算的搜索 变成**状态复用**的递推

$$
dp[state] = min/max/\sum dp[sub_state] + cost
$$
#### 线性递推的动态规划
#### 矩阵的动态规划
#### 字符串的动态规划
对于字符串的动态规划
##### 最长公共子序列
##### 回文问题
- 最长回文字符串

遇到 $s[i] != s[j]$ 时 停止遍历

$$
dp[i][j] = (s[i] == s[j]) \&\& (dp[i+1][j-1] == true)
$$

- 最长回文子序列

与回文字符串的区别在于: 回文字符串在遇到 $s[i] != s[j]$ 时 需要停止遍历 而回文子序列需要继续 因为子序列不要求连续

$$
dp[i][j] = (s[i] == s[j]) \&\& (dp[i+1][j-1] == true)
$$


#### DFS/BFS的动态规划
### 搜索算法
#### BFS
广度优先搜索.

直观的来说 就是浅显的访问同一层的所有节点 然后再去下一层.

用二叉树来直观的看 就是: 先访问一层的所有兄弟节点 然后再往儿子节点去.

用矩阵来直观的看: 先访问上下左右的四个邻居 然后再访问这四个邻居的邻居...

在实现上 BFS使用一个**队列**来记录已经遍历了哪些.

那么BFS具有一个非常好的性质: 

> BFS 算法找到的路径是从起点开始的 最短 合法路

- 遍历二叉树

```rust
#[derive(Debug,PartialEq,Eq)]
pub struct TreeNode<T> {
	pub val: T,
	pub left: Option<Box<TreeNode<T>>>,
	pub right: Option<Box<TreeNode<T>>>,
}

use std::collections::VecDeque;

pub fn bfs(root: TreeNode<T>) -> Vec<T> {
    let mut queue = VecDeque::new();
    let mut result = Vec::new();
    queue.push_back(root);
    while let Some(node) = queue.pop_front() {
        result.push(node.val);
        if let Some(left) = node.left {
            queue.push_back(*left);
        }
        if let Some(right) = node.right {
            queue.push_back(*right);
        }
    }
    result
}

```
	
#### DFS

### 并查集
并查集能很好的处理**连通性**问题.

并查集可以快速的解决两个问题: **查询与合并**.

并查集其实和树结构极其类似 但是: **它更注重于子节点最终属于谁**
```rust
/// 并查集
pub struct Dsu {
	/// 父节点指针
	parent: Vec<usize>,
	/// 
	rank: Vec<usize>,
}
```
#### 一个示例

```
假设有4而城市: 1 2 3 4

一开始每个城市都是独立的 用数组 parent[u]来表示 城市u 的上级

```

那么并查集在这里的**查询**就是: `parent[u]`

而合并操作为: 给定一条道路 比如(1,2) 意味着1与2联通了




## 图
图有两种元素: G = (V,E)

- 顶点Vertex
- 边Edge

根据**边**的性质 图可以分为如下几种

### 图的类型
1. 无向图

边没有方向

2. 有向图

边有方向

3. 加权图

边带有数值

- 特殊图

比如树 二分图
### 图的性质
1. 度: 这个顶点有相邻的边的数量
2. 路径: 顶点的序列.
3. 连通性: 从**任意**一个顶点出发 都能通过路径到达其他顶点.
4. 环: 起始和结束于同一个点的路径
### 抽象为类型
计算机抽象图主要有两个方式
#### 邻接矩阵
一个 $V \times V$ 的 二维数组.

- 若i到j有边 则(i,j)=权重
- 优点: 查询任意两点是否直接相连 O(1)
- 缺点: 空间复杂度大

#### 邻接表
长度为V的数组 每个元素是一个链表

- 数组索引i对应顶点i,其中的元素链表存放了连向的邻居节点.
- 优点: 空间效率高O(V+E) 
- 缺点: 查询两点是否相连需要遍历链表
### 环
判断有向无环图DAG是一个非常广泛的问题 比如Gentoo的Portage循环依赖发现, Linux内核的一些结构,神经网络的计算图. 所以我们将研究 **如何在有向图中判断是否有环**.

主流的两个方法是

1. DFS

2. Kahn拓扑排序

#### DFS
DFS判断有向图里是否有环需要额外维护一个 **三状态信息**

我们看看下面的情况: 我们发现b虽然被访问了两次 但是是两次不同的DFS访问了b 而不是一次DFS访问了两次b

所以需要维护3个状态: 0 没访问过,1 正在访问,2 访问完了

```
a ----> b
      ^
	  |
c-----|
```


## 字符串
### 字符串匹配算法
#### KMP
KMP算法是先预处理一个`pattern`数组 它记录了: 如果匹配到这没匹配成功 就直接跳转相应的位置.

比如
```
a b a b a b c
match
a b a b c
```

我们注意到第一次的abab匹配完后 其实可以直接把ab跳了 注意 不能把abab都跳了.

而KMP算法是求出它的pattern数组 也就是对应跳转多少

```
a b a b c
match
a b a b

-> 
a b a b c
match
    a b a b
```

我们发现 当前缀ab和后缀ab相等时可以跳.

所以这个pattern其实就是前缀与后缀的最长相等长度.

我们可以引入前缀函数的概念了

> 前缀函数的值为 最长的前缀与后缀的相等的长度.
#### 前缀函数算法
KMP的问题转换为了对前缀函数的快速求解问题.

朴素的算法为: 从前往后 和 从后往前匹配

```rust
pub fn prefix_func(s: String) {
	let s = s.bytes();
	let len = s.len();
	let mut prefix_func_arr = vec![0;len];
	for i in 0..len {
		let mut max = 0;
		for k in (1..i+1).rev() {
			let prefix = &s[0..k];
			let suffix = &s[i+1-k..i+1];
			if prefix == suffix {
				prefix_func_arr[i] = k;
				break;
			}
		}
	}
}
```

### Manacher算法
在 $O(N)$ 时间复杂度下 求出以每个位置为回文中心的回文半径.
## 数学算法
### 快速幂
用于在 $\Theta(logn)$时间计算$a^n$的算法.

核心思想为:

将幂按照指数的 **二进制表示** 分割.

举个例子: 假设我要计算$3^7$ 普通的方法是$ 3 * 3 * 3 ... * 3$ 需要7次.

如果使用快速幂 只需要计算4次: $3^2 = 9$ $ 3^3 = 27$ $3^6 = 729$ $3^7 = 2187$


在底下的代码中 base存储的是$2^k$次幂 而exp&1筛选出这个幂是否需要被乘进去
```rust
/// caculate base^exp
fn fast_pow(mut base: u64, mut exp: u32) -> u64 {
    let mut result = 1;

    while exp > 0 {
		// 如果最低位为1 代表这一位代表的指数需要乘进去
        if exp & 1 == 1 {   
			// result = base
            result *= base;
        }
		// 平方底数
        base *= base;
		// 右移指数
        exp >>= 1; 
    }

    result
}
```


### Berlekamp-Massey
求数列的最短递推式的算法.

问题的定义:

给定一个序列 $s_0, s_1, s_2, ..., s_{n-1}$，找到最短的阶的线性递推关系：

$$s_i = \sum_{j=1}^{L} c_j \cdot s_{i-j}$$

其中 $L$ 是递推式的长度也叫**阶** ，$c_1, c_2, ..., c_L$ 是递推系数。

比如斐波那契是二阶

核心思想：

- 从空递推式开始，逐个处理序列元素
- 当当前递推式无法预测下一个元素时，更新递推式
- 使用之前保存的"最佳失配递推式"来修正当前递推式
- 时间复杂度 $O(n^2)$

算法流程：

1. 维护当前递推式 $C(x)$ 和上一个失配时的递推式 $B(x)$
2. 对于每个位置 $i$，计算差值 $\Delta$（当前递推式预测值与实际值的差）
3. 如果 $\Delta \neq 0$，说明当前递推式失配，需要更新
4. 更新时利用 $B(x)$ 来修正 $C(x)$

```rust
/// Berlekamp-Massey 算法求最短线性递推
/// 返回递推系数 [c1, c2, ..., cL]
/// 满足 s[i] = c1*s[i-1] + c2*s[i-2] + ... + cL*s[i-L]
fn berlekamp_massey(s: &[i64], modulo: i64) -> Vec<i64> {
    let n = s.len();
    let mut c = vec![0i64]; // 当前递推式
    let mut b = vec![0i64]; // 上一个失配时的递推式
    let mut l = 0;           // 当前递推式长度
    let mut m = 1;           // 距离上次失配的步数
    let mut old_delta = 1;   // 上次失配的delta值
    
    for i in 0..n {
        // 计算当前递推式的预测值
        let mut delta = s[i];
        for j in 1..=l {
            delta = (delta - c[j] * s[i - j] % modulo + modulo) % modulo;
        }
        
        // 如果预测正确 继续下一个
        if delta == 0 {
            m += 1;
            continue;
        }
        
        // 预测失败 需要更新递推式
        let mut d = c.clone();
        
        // 计算修正系数
        let coef = delta * mod_inv(old_delta, modulo) % modulo;
        
        // 扩展当前递推式长度以容纳修正
        if c.len() < b.len() + m {
            c.resize(b.len() + m, 0);
        }
        
        // 用之前的失配递推式修正当前递推式
        for j in 0..b.len() {
            c[j + m] = (c[j + m] - coef * b[j] % modulo + modulo) % modulo;
        }
        
        // 如果当前长度不够好 更新长度和基准递推式
        if 2 * l <= i {
            l = i + 1 - l;
            b = d;
            old_delta = delta;
            m = 1;
        } else {
            m += 1;
        }
    }
    
    c.truncate(l + 1);
    c
}

/// 计算模逆元 (扩展欧几里得)
fn mod_inv(a: i64, m: i64) -> i64 {
    let (mut a, mut m) = (a, m);
    let (mut x0, mut x1) = (1, 0);
    
    while m != 0 {
        let q = a / m;
        let temp = m;
        m = a % m;
        a = temp;
        
        let temp = x1;
        x1 = x0 - q * x1;
        x0 = temp;
    }
    
    (x0 % m + m) % m
}
```

应用场景：

- 密码学：分析线性反馈移位寄存器(LFSR)
- 编码理论：纠错码的解码
- 竞赛：已知数列前n项求通项公式
- 矩阵快速幂优化：求递推数列第n项


### 质因数分解
#### 试除法
对n 用2,3,5,7...整除 当除数大于$\sqrt{n}$停止.

#### Pollard Rho算法



### 最大公因数gcd
#### 欧几里得算法
```rust
fn gcd(a: i32, b: i32) -> i32 {
        if b == 0 {
        a
    } else {
        Self::gcd(b, a % b)
    }
```
这个算法的思想是:

若 a和b有最大公约数

那么

$$
a = qb + r
$$

假设

$$
d = gcd(a,b)
$$

而

$$
r = a - qb
$$

我们假设 a = md , b = nd

则

$$
r = (m - qn) d
$$


所以

$$\boxed{d也整除r}$$

所以我们只需要求

$$
gcd(a,r) = gcd(a, a mod b)
$$
### 容斥原理

$$
|\bigcup_{i=1}^{n} A_i| = \sum_{i=1}^{n} |A_i| - \sum_{1 \leq i \< j \leq n} |A_i \cap A_j| + \sum_{1 \leq i < j < k \leq n} |A_i \cap A_j \cap A_k ... + (-1)^{n-1} |A_1 \cap ... \cap A_n|
$$

常用的有两个集合的与三个集合的

$$
|A \cup B| = |A| + |B| - |A \cap B|

|A \cup B \cup C| = |A| + |B| + |B| - |A \cap B| - |A \cap C| - |B \cap C| + |A \cap B \cap C|
$$
## RMQ
区间最大/最小值
