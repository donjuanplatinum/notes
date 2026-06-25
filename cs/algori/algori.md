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

