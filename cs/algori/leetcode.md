# LeetCode

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
