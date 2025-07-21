# 算法

## 两数之和

我们的思路是 创建一个`HashMap` 并逐步把数组里的元素推进去. 每次推进去一个元素后

我们计算这个元素与需要的和的差值`sub`, 在Map中寻找有没有这个`sub`的存在 存在则返回当前元素 与`sub`元素的下标

Rust实现
```rust
pub fn two_sum<T: Hash + Eq + Clone + core::ops::Sub<Output = T>>(
    array: &[T],
    target: &T,
) -> Result<(usize, usize), ()> {
    let mut table: HashMap<&T, usize> = HashMap::new();
    for i in 0..array.len() {
        let sub = target.clone() - array[i].clone();
        match table.get(&sub) {
            Some(index) => {
                return Ok((*index, i));
            }
            None => {
                table.insert(&array[i], i);
            }
        }
    }
    return Err(());
}
```

