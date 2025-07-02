# 算法第四版

## 基础编程模型

### 编写一个静态方法lg() 接收一个整型参数N 返回不大于 $log_2{N}$ 的最大整数
``` rust
fn lg(num: i32) -> i32 {
    if num <= 1 {return 0};
    let mut n: i32 = 0;
    while pow(2,n) <= num {
	println!("n: {}, 2^n:{}, num: {}",n,2^n,num);
	n += 1;
    }
    return n - 1;
}

fn pow(num: i32, n: i32) -> i32{
    println!("n: {}",n);
    if n == 0 {
	return 1;
    }
    return num * pow(num,n-1);
}

```
### 编写一个静态的递归方法计算 $ln{N!}$
``` rust
fn ln(num: f32) -> Result<f32, ()> {
    if num < 0.0 {
        return Err(());
    }
    if num == 1.0 {
        return Ok(0.0);
    }
    return Ok(num.ln() + ln(num - 1.0).unwrap());
}


```


