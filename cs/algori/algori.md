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
