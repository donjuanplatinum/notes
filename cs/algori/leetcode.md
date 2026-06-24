# LeetCode
LeetCode我的题解

| 题号 | 题目              | 类别                                       | 难度 |
| 3699 | 锯齿形数组的总数I | 动态规划 组合数学(解法2) 前缀和优化(解法1) | 困难 |
## 1518.换水问题
### 题目
```
超市正在促销，你可以用 numExchange 个空水瓶从超市兑换一瓶水。最开始，你一共购入了 numBottles 瓶水。

如果喝掉了水瓶中的水，那么水瓶就会变成空的。

给你两个整数 numBottles 和 numExchange ，返回你 最多 可以喝到多少瓶水。
```

### 解析
其实这个问题有点像游戏抽奖 我花x块钱抽奖 每抽y块钱返还我z块钱 我一共能抽多少次

我们可以注意到 你能换的空瓶的数量是可计算的

每喝m瓶水,获得m个瓶子,可兑换m / numExchange个水,然后剩下m / numExchange + m % numExhange瓶水,直到剩下的瓶子<numExchange时不能兑换.

所以我们发现这是个递归问题 当然也一个循环解决

我们发现`兑换后的空瓶子 = 空瓶子 / numExchange + 空瓶子 % numExchange`

然后再用兑换后的空瓶子去重复这个过程

于是我们得到
```rust
/// 计算可以兑换的水的数量
fn calculate_empty(exchange: usize,empty: usize) -> usize {
	if empty < exchange {return 0;} // 当空瓶子 < 交换数量时 返回0
	let water = empty / exchange; // 此轮兑换的水数量
	let empty = water + empty % exchange; // 这一轮剩下的空瓶子
	return water + caculate_empty(exchange,empty); // 这一轮换的水 + 下一轮换的水
}
```


我们其实也可以通过外部变量把递归改成循环
```rust
fn exchange_water(exchange: usize,waters: usize) -> usize{
    let mut waters: usize = waters.clone(); // 目前换的水的数量
    let mut empty: usize = waters.clone(); // 目前空瓶子数量
    while empty >= exchange { // 当空瓶子还能换时继续换
	let new = empty / exchange; // 这一轮能换的水数量
	waters += new; // 累加上去
	empty = new + empty % exchange; // 空瓶子数量更新
    }
    return waters;
}
```
## 2221.数组的三角和
### 题目
```
给你一个下标从 0 开始的整数数组 nums ，其中 nums[i] 是 0 到 9 之间（两者都包含）的一个数字。

nums 的 三角和 是执行以下操作以后最后剩下元素的值：

nums 初始包含 n 个元素。如果 n == 1 ，终止 操作。否则，创建 一个新的下标从 0 开始的长度为 n - 1 的整数数组 newNums 。
对于满足 0 <= i < n - 1 的下标 i ，newNums[i] 赋值 为 (nums[i] + nums[i+1]) % 10 ，% 表示取余运算。
将 newNums 替换 数组 nums 。
从步骤 1 开始 重复 整个过程。
请你返回 nums 的三角和。
```
### 解析
事实上 这其实就是差分 然后差分到n-1阶而已. 我们可以根据n阶差分的公式直接得到结果.

但是我们仍旧从朴素的方法开始

我们可以用队列来解决这个问题: 1,2,3,4,5

先加入1 然后加入2, 相加后弹出1, 然后入队3. 然后一直到5,5后面没有元素入队便结束

我们可确定两点 1. 只用处理n-1次差分 2. 一次差分需处理 len -1 次

于是我们得到了双端队列解法
``` rust
fn sanjiaohe(array: Vec<i32>) -> i32 {
    let mut deque = VecDeque::from(array); 
    let len = deque.len();
    for i in 0..len-1 { // 要处理n-1层
		let deque_len = len - i; // 这一层的元素长度
		for j in 0..deque_len-1 { // 这一层的元素要处理的次数len -1
			let a = deque.pop_front().unwrap(); // 先把头弹出
			deque.push_back((a + deque[0]) % 10); // 把加好后的入队到队尾
	}
		deque.pop_front(); // 每层处理后队头会多出一个元素 弹出它
    }
    deque[0]
}
```

但是我们会发现这个解法用了额外的空间 事实上,我们可以使用原址处理
```rust
fn sanjiaohe(mut array: Vec<i32>) -> i32 {
    let len = array.len();
    for i in 0..len-1 { // 要处理n-1层
		for j in 0..len-1-i { // 这一层的元素要处理的次数len -1
		array[j] = (array[j] + array[j+1]) % 10;
	}
	array.pop(); // 队尾会多出元素 弹出即可
    }
    array[0]
}
```

## 3100.换水问题II
### 题目
```
给你两个整数 numBottles 和 numExchange 。

numBottles 代表你最初拥有的满水瓶数量。在一次操作中，你可以执行以下操作之一：

喝掉任意数量的满水瓶，使它们变成空水瓶。
用 numExchange 个空水瓶交换一个满水瓶。然后，将 numExchange 的值增加 1 。
注意，你不能使用相同的 numExchange 值交换多批空水瓶。例如，如果 numBottles == 3 并且 numExchange == 1 ，则不能用 3 个空水瓶交换成 3 个满水瓶。

返回你 最多 可以喝到多少瓶水。
```
### 解析
其实这就是相当于1518变成了每次只兑换一瓶然后下次兑换一瓶时要多加个空瓶子
```rust
fn exchange_water(exchange: usize,waters: usize) -> usize{
    let mut exchange = exchange;
    let mut waters: usize = waters.clone(); // 目前换的水的数量
    let mut empty: usize = waters.clone(); // 目前空瓶子数量
    while empty >= exchange { // 当空瓶子还能换时继续换
	waters += 1; // 累加一个
	empty = empty -exchange + 1; // 空瓶子
	exchange += 1; // 要换的数量+1
    }
    return waters;
}

```

但事实上 其实有个数学规律在里面

令空瓶换水次数为t 交换的总空瓶为empty瓶 产生的总空瓶为total 则有 $empty \leq total$

由于每次换水所需的空瓶数都+1 则 

$$ 
empty = \sum_{i=0}^{t-1}(exchange + i) 
$$

则

$$
empty = t \cdot exchange + t(t-1) /2
$$

而
$$
total = bottles + t
$$

则
$$
t \cdot exchange + t(t-1) /2 - bottles + t \leq 0
$$
## 42.接雨水
### 题目
```
给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。
```
### 解析
实际上我们可发现 每个index的雨水量和左右两边最高的柱子有关系

$$
rain = min(left_max,right_max) - current_height
$$

而我们可以通过两个数组分别存储从左开始的最高柱子高度 和 从右开始的最高柱子高度

比如对于 [0,1,0,2,1,0,1,3,2,1,2,1]

它的left_max数组为 [0,1,1,2,2,2,2,3,3,3,3,3]

right_max为 [3,3,3,3,3,3,3,3,2,2,2,1]

那么
```
rain[0] = min(left_max[0],right_max[0]) - height[0];

rain[1] = min(left_max[1],right_max[1]) - heigt[1];
```

``` rust
fn trap_rain_water(height_map: Vec<i32>) -> i32  {
    let len = height_map.len(); // 高度表长度
    let mut left_max = vec!(0;len); // 初始化从左开始最大值表
    let mut right_max = vec!(0;len); 
    let mut max_index = 0; 
    for i in 0..len { // 遍历并得到从左开始最大值表
	if height_map[i] > height_map[max_index] {
	    max_index = i;
	}
	left_max[i] = height_map[max_index];
    }
    max_index = len -1;
    for j in (0..len).rev() {
	if height_map[j] > height_map[max_index] {
	    max_index = j;
	}
	right_max[j] = height_map[max_index];
    }
    let mut rain =0; // rain的总量
    for i in 0..len {
	let cur_rain = min(left_max[i],right_max[i]) - height_map[i]; // 套公式
	rain += cur_rain;
    }
    rain
}

```


然而我们可以不用构建这两个最大值数组 而使用双指针来解决

我们维护一个左指针和右指针 分别指向左边和右边遍历的最大值的位置

若左边小于右边的最大值时 最大接水量由左边决定
```rust
fn trap(height: Vec<i32>) -> i32 {
    if height.len() <= 2 {
        return 0;
    }
    
    let mut left = 0;
    let mut right = height.len() - 1;
    let mut left_max = left;
    let mut right_max =  right;
    let mut total_water = 0;

    while left < right {
        if height[left_max] <= height[right_max] { // 左最大 <= 右
            left += 1; // 左右移
	    if height[left_max] < height[left] {  // 左最大值更新
			left_max = left;
	    }
            total_water += height[left_max] - height[left]; // 套公式
        } else {
            right -= 1;
	    if height[right_max] < height[right] {
		right_max = right;
	    }
	    total_water += height[right_max] - height[right];
        }
    }
    total_water
}

```

## 407.接雨水II
### 题目
```
给你一个 m x n 的矩阵，其中的值均为非负整数，代表二维高度图每个单元的高度，请计算图中形状最多能接多少体积的雨水。
```
## 1344. 时钟指针夹角
### 题目
### 题解
给定`hour_i32`和`minutes_32`给出 时针和分针的夹角.

我们只需要把 `hour` 和 `minutes` 给映射到360度 然后做差即可.

- 对于`hour`
  
  $hour_angel_1 = \frac{hour}{12} \times 360 = hour \times 30$
  
  注意 在生活中 比如12.30 时针不会指在12 而是12的中间
  
  所以 还应该加 分钟对应的角度对于12小时的分量
  
  $hour_angle_2 = \frac{minutes}{60} \times {360} / 12 = \frac{1}{2} minutes $ 
  
  即为
  
  $hour_angle = \frac{1}{2} minutes + hour \times 30$ 
  
- 对于`minutes`

  $minutes_angle = \frac{minutes}{60} \times 360 = 6 \times minutes$

  合并为: $metric = hour \times 30 + \frac{1}{2} minutes -  6 \times minutes = 30 \times hour - 5.5 \times minutes$
  
- 对于最终结果

  由于是最小角度 我们需要角度 **小于 180** 也就是说 :  当角度小于180时返回;大于180时用360度去减
  
  实际上可以用**绝对值**函数来映射这个 因为在计算机底层 **绝对值的计算远比条件判断块** 

  $metric = 180 - \| metric - 180 \|$
```rust
impl Solution {
    #[inline(always)]
    pub fn angle_clock(hour: i32, minutes: i32) -> f64 {
        let h = (hour % 12) as f64;
        let m = minutes as f64;

        let raw_diff = (h * 30.0 - m * 5.5).abs();

        180.0 - (180.0 - raw_diff).abs()
    }
}
```
## 3699. 锯齿形数组的总数I
这道题是DP动态规划问题 然后涉及到一个前缀和优化(解法1) 同时还有一个数学上的更优的解(解法2)

### 题目
```
给你 三个整数 n、l 和 r。

长度为 n 的锯齿形数组定义如下：

每个元素的取值范围为 [l, r]。
任意 两个 相邻的元素都不相等。
任意 三个 连续的元素不能构成一个 严格递增 或 严格递减 的序列。
返回满足条件的锯齿形数组的总数。

由于答案可能很大，请将结果对 109 + 7 取余数。

序列 被称为 严格递增 需要满足：当且仅当每个元素都严格大于它的前一个元素（如果存在）。

序列 被称为 严格递减 需要满足，当且仅当每个元素都严格小于它的前一个元素（如果存在）。
```

### 题解
#### 动态规划 前缀和
根据 **任意两个元素不相等**,**任意3个连续元素不能构成严格的增减性** 我们可以发现: 整个数组的增减其实是固定的 只有两个情况

1. 增->减->增->减...
2. 减->增->减->增...

和两个情况是完全**对称**的 所以我们只需要研究模式1.

值域为`[l,r]`,我们其实把它平移到`[1,1+l-r]`是一样的.

我们发现: **当我们想要添加下一个元素时 能对它有约束的只有当前最后一个元素**. 即: array[i]只与array[i-1]有关. 所以我们使用**动态规划DP**.

这个时候我们定义动态规划:

$$
dp[i][x]
$$

其中
- i: 数组的长度
- x: 这个数组的最后一个元素


我们来研究这个DP:

- 初始状态时: `i=1`. $dp[1][x] = 1$
- 状态转移时:

对于递增时: $dp[i][x] = \sum_{u=1}^{x-1} dp[i-1][u]$

对于递减时: $dp[i][x] = \sum_{u=x+1}^{1+l-r} dp[i-1][u]$

我们还发现有一个地推式,它揭示了dp[i][x]与dp[i][x-1]的关系: $dp[i][x] = dp[i][x-1] + dp[i-1][x-1]$

而dp[i][1] = 0

我们可以根据这个地推式得到dp[i][x] 这是O(1+l-r)=O(m)时间

```rust
let dp[1][x] = 1;
let dp[i][1] = 0

for x in 2..(1+l-r) {
	dp[i][x] = dp[i][x-1] + dp[i-1][x-1]
}
```


根据这个式子 可以在O(n*(1+l-r))=O(n*m)时间填完

代码为:
```rust
impl Solution {
    pub fn zig_zag_arrays(n: i32, l: i32, r: i32) -> i32 {
        const MOD: i64 = 1_000_000_007;
		// 数组长度n
        let n = n as usize;
		// 平移后的值域大小m=1+r-l
        let m = (r - l + 1) as usize; 
		
		// 值域为0直接返回0
        if m == 0 {
            return 0;
        }

        // 累加dp[1][1] dp[1][2] .. dp[1][m] 而dp[1][x]= 1
        if n == 1 {
            return m as i32;
        }
		
		// 用dp_prev[x]表示dp[i-1][x]
        let mut dp_prev = vec![1i64; m + 1];
        dp_prev[0] = 0;

        // 从长度 2 递推到 n 遍历出所有的dp表
        for i in 2..n+1 {
			// dp_curr[x]表示dp[i][x]
            let mut dp_curr = vec![0i64; m + 1];
            if i % 2 == 0 {
                // 偶数步 递增
                for x in 2..m+1 {
					// dp[i][x] = dp[i][x-1] + dp[i-1][x-1]
                    dp_curr[x] = (dp_curr[x - 1] + dp_prev[x - 1]) % MOD;
                }
            } else {
                // 奇数步 递减
                for x in (1..=m - 1).rev() {
					// dp[i][x] = dp[i][x-1] + dp[i-1][x-1]
                    dp_curr[x] = (dp_curr[x + 1] + dp_prev[x + 1]) % MOD;
                }
            }
            dp_prev = dp_curr;
        }

        
        let ans_a: i64 = dp_prev.iter().sum::<i64>() % MOD;

        let total = if n >= 2 { (ans_a * 2) % MOD } else { ans_a };
        total as i32
    }
}
```

#### 离散数学
我们来看一下dp的数组:

- $dp[1][x] = 1$
- $dp[2][x] = \sum_{u=1}^{x-1} dp[1][u] = x - 1$ 相当于对dp[1][x]求前缀和
- $dp[3][x] = \sum_{u=x+1}^{1+j-r} dp[2][u]$ 相当于对dp[2][x] 相当于求后缀和 而后缀和可以写为总数减前缀和 $sum_{u=1}^{M} dp[2][u] - sum_{u=1}^{x} dp[2][u]$ 其中总数是常数.

我们发现: dp[i][x]中的i每增加1, 会求一次前缀和. 在离散数学中 求前缀和相当于一次积分 所以dp[3][x]会是二次多项式 dp[i][x]会是 i-1次多项式.

>也就是说 dp[i][x]被一个i-1次多项式描述.

那我们直接存储i个系数即可.

我们来思考多项式基底:

之前我们一直使用的是 ${1,x,x^2,...}$的多项式基底. 这组基底计算前缀和是很难得到闭合解的. $\sum_{u=1}^{x-1} u^k$ 这个是等幂求和问题 结果好像是有第二类斯特林数和伯努利数.

这个时候我们考虑**组合数基底**:

$$ \mathcal{B} = \left\{ \binom{x-1}{0}, \binom{x-1}{1}, \binom{x-1}{2}, \dots \right\} $$

我们来看看前缀和与后缀和:

- 前缀和:

$$

\sum_{u=1}^{x-1} \binom{u-1}{k} = \binom{x-1}{k+1}

$$


- 后缀和:

$$

\sum_{u=x+1}^{l-r+1} \binom{u-1}{k} = \binom{l-r+1}{k+1} - \binom{x}{k+1}

$$

相当于: 
>前缀和与后缀和变成了线性变换.

那么我们将dp换基底表示为:

$$
dp[i][x] = c_0 \binom{x-1}{0} + c_1 \binom{x-1}{1} + .. + c_{i-1} \binom{x-1}{i-1}
$$

我们来试着将原来的dp表示一下

- dp[1][x] = 1 那么 就是 1 * $\binom{x-1}{0}$ 则c_0为1
- dp[2][x] = x - 1 那么 即为 c_1 为1

我们来思考 如何得到**升步的**行系数 $c = [c_0,c_1,...,c_n]$

$$
dp[i][x] = \sum_{u=1}^{x-1} dp[i-1][u]
$$

我们知道 $dp[i-1][u] =\sum_{k=1}^{u-1} c_k \binom{u-1}{k}$

那么

$$
dp[i][x] = \sum_{u=1}^{x-1} (\sum_k c_k \binom{u-1}{k})
$$

交换次序

$$
dp[i][x] = \sum_k c_k (\sum_{u=1}{x-1} \binom{u-1}{k})
$$

由等式 

$$
\sum_{u=1}{x-1} \binom{u-1}{k} = \binom{x-1}{k+1}
$$

带入后得到

$$
dp[i][x] = \sum_k c_k \binom{x-1}{k+1}
$$

我们发现 其实升步后 dp[i][x]的系数就是c**右移一位**. dp[i-1][x]是[c_0,c_1,...,c_k] dp[i][x]是[0,c_0,c_1,...,c_k].


降步的形式不太一样 通过类似的过程可以得到

dp[i-1][x]是[c_0,c_1,..,c_k] 则dp[i][x]是

$$
[\sum_k c_k \binom{l-r+1}{k+1},-c_1-c_0,-c_2-c_1,...,-c_k-c_{k-1}]
$$

我们现在可以考察最终的结果

我们需要求得

$$
\sum_{x=1}^{M} dp[n][x]
$$

即为

$$
\sum_{x=1}^{M} \sum_k c_k \binom{x-1}{k} = \sum_k c_k \binom{M}{k+1}
$$

我们只需要得到: c_k 与 C(M,k+1)的点积即可.


我们总结一下步骤

1. 计算组合数 $\binom{M}{k}$ 这个是满足与k-1的递推的.
```rust
let maxk = n + 1;
// comb[k] = \binom{m}{k}
let mut comb = vec![1i64; maxk + 1];
for k in 1..=maxk {
	// C(m,k) = \frac{m-k+1}{k} C(m,k-1)
    comb[k] = comb[k - 1] * (m - k as i64 + 1) % Self::MOD;
	// 使用摸逆元实现除法
    comb[k] = comb[k] * Self::mod_inv(k as i64) % Self::MOD;
}
```
2. 计算系数向量

```rust
 for i in 2..=n {
            if i % 2 == 0 {
                // 升步：右移
                let mut new_c = vec![0i64; coeffs.len() + 1];
                new_c[1..].copy_from_slice(&coeffs);
                coeffs = new_c;
            } else {
                // 降步
                let len = coeffs.len();
                let mut new_c = vec![0i64; len + 1];
				
				// 计算c_0
                let mut sum_cm = 0i64;
                for j in 0..len {
                    sum_cm = (sum_cm + coeffs[j] * comb[j + 1]) % Self::MOD;
                }
                new_c[0] = (sum_cm - coeffs[0]) % Self::MOD;
				
				// c_i = -c_i - c_{i-1}
                for k in 1..=len {
                    let ck = if k < len { coeffs[k] } else { 0 };
                    let ck1 = coeffs[k - 1];
                    new_c[k] = (-ck - ck1) % Self::MOD;
                }
                coeffs = new_c;
            }
        }
```

3. 计算最终答案

```rust
	    // 计算 ans_A = Σ c_k * C(m, k+1)
        let mut ans_a = 0i64;
        for k in 0..coeffs.len() {
            ans_a = (ans_a + coeffs[k] * comb[k + 1]) % Self::MOD;
        }
        let total = (ans_a * 2) % Self::MOD;
        ((total + Self::MOD) % Self::MOD) as i32
```
