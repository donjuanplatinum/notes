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


