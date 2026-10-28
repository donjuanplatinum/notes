# 算法
## Hash算法
## 数据结构
### 基本数据结构
最基本的数据结构.
#### 背包
基本所有的数据结构都是背包.

背包的定义为:

1. 可以往里面放对象
2. 不规定顺序的取出对象
#### stack
栈是最基本的数据结构之一. 操作系统的内存模型中 栈有很大一部分比例.

可以把栈理解为 **堆盘子**. 你只能往**最上面**放盘子 也只能从**最上面**拿盘子.

所以栈的访问顺序是LIFO(last in first out) **后进先出**.

rust的`Vec<T>`如果只使用`pop()`与`push()` 那么就是个栈.

#### queue
队列与栈不同 队列是FIFO(first in first out) 先进先出.

队列就是最基础的人类的排队. 先来的先处理

#### linkedlist
链表和数组类似 但是链表的插入与删除是`O(1)` 不过查询却是`O(n)`. 但是由于链表在内存里 通常不像数组是**连续**的, 所以缓存命中率没数组高.

但是我们可以加个`HashMap` 来让 插入 删除 查询都是`O(1)`.

标准库的实现是
```rust
pub struct LinkedList<
    T,
    #[unstable(feature = "allocator_api", issue = "32838")] A: Allocator = Global,
> {
    head: Option<NonNull<Node<T>>>,
    tail: Option<NonNull<Node<T>>>,
    len: usize,
    alloc: A,
    marker: PhantomData<Box<Node<T>, A>>,
}

struct Node<T> {
    next: Option<NonNull<Node<T>>>,
    prev: Option<NonNull<Node<T>>>,
    element: T,
}
```

这其中, `LinkedList<T,A>`是链表, `Node<T>`是其中的节点.
- `head`: 指向双向链表的头
- `tail`: 指向双向链表的尾
- `len`: 双向链表的长度
- `next`: 指向下一个节点的指针
- `prev`: 指向上一个节点的指针
- `element`: 存储的元素
##### 与哈希表结合
如果链表是 **可侵入**的, 也就是说 在这个编程语言里, 它的节点的接口是暴露且可访问的. 

那么可以使用`HashMap`存放节点 并在`O(1)`时间访问到链表的任意节点.

但是我们rust标准库的`LinkedList`是不暴露Node接口的.所以rust需要手动实现.

具体而言

只需要维护一个额外的`HashMap`.

```rust
HashMap<K,Node>
```

那么通过K可以直接得到这个节点. 并方便的插入修改链表
#### 哈希表
哈希表的实现要灵活很多 有很多不同的哈希算法 需要针对不同的场景选择.

哈希表可以通过KV(key-value)查询.

插入O(1) 查询(1).

它是通过 一个 **数学函数** `f` ,将可hash化的K 映射为索引.

然后直接在索引里去O(1)查找.

值得介绍的一个算法是Rust标准库的 `SwiwssTable`
##### SwissTable

### 并查集
并查集能很好的处理**连通性**问题.

并查集可以快速的解决两个问题: **查询与合并**.

并查集其实和树结构极其类似 但是: **它更注重于子节点最终属于谁**.

两个核心操作是
- `find(x)`: 查询某个元素所属的集合. 用于判断两个元素是否属于一个集合. `find(x) ?= find(y)`
- `union(x,y)`: 合并两个元素所属集合.

然后还有几个小优化:

1. 路径压缩: 在`find`的过程中 顺便把沿途节点直接指向根节点.
2. 额外维护一个`rank`数组, 表示树高的上界, 合并的时候先找到根 然后比较根的rank.

要合并的两个节点中, 我们找到rank更小的节点, 把rank更小的节点挂到更大的节点下面.

这样做的原因是: rank不同的时候 低rank的根挂到高rank的根下面 这样树高不会增加很多.

在rank优化的情况下 树高最高为 $O(\log n)$ .

在这两个优化的情况下, `find`和`union`的时间复杂度**均摊**为 $O(\alpha (n))$

其中 $\alpha (n)$为 **反阿克曼函数** 这个函数的增长速度**非常非常非常的慢**.

```rust
/// 并查集
pub struct DSU {
	/// 父节点指针
	parent: Vec<usize>,
	/// 秩
	rank: Vec<usize>,
}
```



### 维护序关系的数据结构
很多时候 对象是有 **序** 的. 在我们rust里叫 实现了`Ord`与`Eq`.

那么我们可以通过利用它们的序关系 来优化数据结构 使得时间复杂度降低.

#### 单调栈

### 区间数据结构
对区间进行操作的数据结构.

在实际的算法问题中, 我们经常需要: 如何高效的维护一个序列的**区间信息**.

为此 我们建立一个统一点的模型.

给定数组

$$
a_1,a_2,\cdots,a_n
$$

主要的两种操作为: 查询与修改

- 查询: 查询 `[l,r]` 区间的信息, 比如它们的 **和**, **积**, **最大值** ...
- 修改: 修改了 $a_i$ 或者修改了 $a_i,\cdots,a_j$ 

于是产生了如下不同的数据结构:

| 数据结构 | 初始建表                              | 查询                                         | 修改              | 表的空间复杂度 |
|----------|---------------------------------------|----------------------------------------------|-------------------|----------------|
| 前缀和   | O(n)                                  | O(1)                                         | O(n)              | O(n)           |
| 差分数组 | O(n)                                  |                                              | O(1)              | O(n)           |
| ST表     | O(nlogn)                              | O(1)                                         |                   | O(nlogn)       |
| 线段树   | O(n)                                  | O(logn)                                      | 单点/区间 O(logn) | O(n)           |
| 树状数组 | O(n)                                  | O(logn)                                      | 单点 O(logn)      | O(n)           |
| 区间树   | 从头构建 O(nlogn) / 有序数据构建 O(n) | 找到任意一个重叠的O(logn)/找到所有重叠的O(n) | O(logn)           |                |

#### 前缀和
不推荐修改 只查询.  维护`[l,r]`的 **和**

花费O(n)的时间建表 然后O(1)的时间 可以求出 `\sum_{i=l}^r a_i`.

令 

$$
prefix[i] = \sum_{j=1}^{i} a_j
$$

那么

$$
\sum_{i=l}^{r} a_i = prefix[r] - prefix[l-1]
$$

比如 原数组 `arr = [1,2,3,4,5,6]`

前缀和数组为: `prefix = [1,3,6,10,15,21]`

那么查询 原数组的 [2,5] 的**和** 就是: `prefix[5] - prefix[1]`

#### 差分数组
推荐修改. 维护 原数组的 **一阶差分** 但是保留第一个数.

花费O(n)的时间建表 花费O(1)的时间 可以对区间**修改**

与前缀和的不同是: **前缀和能方便的查询 而差分数组能方便的修改**.

令
$$
diff[1] = a_1 \\
diff[i] = a_i - a_{i-1} , i > 1
$$

那么 假如 对 区间[l,r] 所有元素 + n, 做下面两个操作即可.

- $diff[l] += n$ 
- $diff[r+1] -= n$

比如 原数组 `arr = [1,2,5,9,23,25,50]`

差分数组为: `diff = [1,1,3,4,14,2,25]`

那么给arr的[3,5]都加10就是: `diff[3] + 10, diff[6] - 10`

得到了 `diff = [1,1,13,4,14,2,15]`

恢复就是 `arr = [1,2,15,19,33,35,50]`

#### 稀疏表(ST表)
ST表专门用来做 **静态数组区间查询**. 而且很适合处理 **可重复贡献问题**.

- 可重复贡献问题指的是 对于一个算子L, L(x,x) = x. 也就是说 max,gcd都是L算子

ST表存储: **从每个位置开始 长度为$2^k$的区间答案** , 也就是使用**倍增**思想.

花费O(nlogn)时间建表 表O(nlogn)大小 花费O(1)时间**查询**

ST表的存储为:

$$
st[k][i]
$$

> **表示 从下标i开始 长度为$2^k$的区间的答案**.


比如 原数组 `arr = [2,3,5,1,4,6,7,0]` 我们要存**最大值**.

- st[0][] = [2] [3] [5] [1] [4] [6] [7] [0]
- st[1][] = [3] [5] [5] [4] [6] [7] [7]
- st[2][] = [5] [5] [6] [7] [7]
- st[3][] = [7]

那么对于任意的`[l,r]`, 我们O(1)时间可以得到答案

比如[3,6]. 我们先算距离大小: `6 - 3 + 1 = 4` 那么直接是st[2][3].

比如[1,5]. 距离为: `5 - 1 + 1 = 5` 我们直接取: [1,4] 与 [2,5] 取max.

也就是说: [1,4]与[2,5]可以求最大值为[1,5].

这也就是为什么要求ST表解决: **可重复问题** 也就是`f(x,x)=x`, 否则重复将直接失效.
#### 线段树(Seg tree)
对一个数组 快速进行**区间查询**与**修改**.

- ST表 建表需要`O(nlogn)` 查询只要 `O(1)` 但修改不是很方便.
- 线段树 建表需要`O(n)` 查询需要`O(logn)` 但是单点修改与区间修改只需要`O(logn)`

**线段树**的修改是方便于**ST表**的.

具体而言 线段树是一颗**二叉树**. 它**自顶向下**的二分区间.

比如原数组 `arr = [2,3,5,1,4,6,8,9]`

- root: `[2,3,5,1,4,6,8,9]`
- root的左孩子与右孩子: `[2,3,5,1]`,`[4,6,8,9]`
- ....
- `[2] [3] [5] [1] [4] [6] [8] [9]`

一共`logn`层

- 假设我们查询区间[2,6]的最大值, 那么[2,3],[4,5],[5,6]覆盖这个区间. 通常只需要查询O(logn)个区间 就可以覆盖这个区间.  所以查询是O(logn).

如果在root向下查询的时候 遇到了lazy标签 就把lazy标签累计上 最后子节点一起加起来

- 单点修改的话 每层改一个值即可 一共logn层
- 区间修改比较特殊 借助`lazy propagation`懒标记 将本来需要给整个子树做的操作 在它们的父节点就打个标记.

假设arr有16个元素. 我们需要修改[5,14] 都+10.

区间树会寻找完全覆盖[5,14]的几个节点: [5,8],[9,12],[13,14].

我们先把这几个节点都修改: `sum[5,8] += 4*10` `sum[9,12] += 4*10`.

但是我们不去修改子节点: 比如[5,6] [7,8] [9,10] [11,12]

我们记录 lazy[5,8] = 10, lazy[9,12] = 10.

这样当我们查询[5,6]的时候: [1,16] -> [1,8] -> [5,8]. 看看有哪些lazy 然后加一起.

这样而来: 对于区间修改, 我们只需要修改O(logn)个节点 并给它们打lazy标记. 而查询的时候需要遍历最多logn层的祖先 来看看有没有lazy.

这样就保证了区间修改也是O(logn)
#### 区间树(Interval tree)
我们会借助Emacs的`intervals.c`与`itree.c`来讲解, 这是非常模范的实现. 具体请看Emacs的区间树章节.

区间树可以高效的找到 **与给定区间重叠的所有区间**.

朴素的方法是: 遍历所有的区间 并测试是否相交. 这需要 O(n)时间.
#### 树状数组
树状数组是**前缀和**与**差分**的推广,用于解决 前缀和的修改的问题.

树状数组在实现层面比线段树简单不少, 因为树状数组使用**差分思想** 而线段树需要lazy标签等操作.

树状数组要求 元素满足: **结合律** 与 **可差分**.

树状数组 使用O(n)时间建表,O(logn)区间查询,O(logn)单点修改.

- **线段树**是将数组使用二叉树分为了高度为`logn`的树 它存放不同的**区间信息**
- **树状数组**是将数组的前缀和分为了最多`logn`个区间

树状数组建的表比较特殊:

原数组为 `arr = [2,3,5,1,4,6,8,9]`

我们下标从1开始,因为树状数组需要lowbit运算

- tree[1] = arr[1]
- tree[2] = arr[1..=2]
- tree[3] = arr[3]
- tree[4] = arr[1..=4]
- tree[5] = arr[5]
- tree[6] = arr[5..=6]

$$
tree[n] = \sum_{i = n - lowbit(n) + 1} ^{n} arr[i]
$$

- lowbit(n) = i & (-i) ,表示二进制中最低位1所代表的值

比如 tree[6], lowbit(110) = 2, tree[6] = arr[5] + arr[6]

- 区间查询: 我们使用前缀和来查询区间. 假设要求`prefix_sum[6]`, 那么直接 `i <- i - lowbit(i)` 遍历.

1. lowbit(6) = 2, 6 - 2 = 4 , 取 tree[6]
2. lowbit(4) = 4 , 4 - 4 = 0 , 取 tree[4]

即 prefix_sum[6] = tree[4] + tree[6]

我们实际上是在一次次消耗掉最低位的1,而最多只有`logn`位 所以`O(logn)` 时间可以查询 前缀和. 而两个前缀和可以得到区间查询.

- 单点修改: 假设我们要修改 arr[5].

那么取 `i <- i + lowbit(i)` 遍历.

1. lowbit(5) = 1, 5 + 1 = 6, 取tree[5]
2. lowbit(6) = 2, 6 + 2 = 8, 取tree[6]
3. lowbit(8) = 8, 8 + 8 = 16. 取tree[8]
4. ... 知道 i 超过了n为止.

然后给这些节点都修改即可. 这些区间刚好包含arr[5].

### 树
树的用途挺多的 树也是图的一种

| 数据结构          | 用途                           | 操作           | 思想                                  |
|-------------------|--------------------------------|----------------|---------------------------------------|
| 二叉树            | 只是一个模型                   | 遍历与增删     | 每个节点最多2个孩子                   |
| BST 二叉搜索树    | 有序数据快速查找               | 搜索 插入 删除 | left < parrent < right                |
| BinaryHeap 二叉堆 | 维护一个**有序**的结构         | 搜索 插入 删除 | parrent > child                       |
| AVL 平衡二叉树    | 解决BST的退化问题              | 搜索 插入 删除 | 二叉树可能退化为链表,通过旋转控制高度 |
| RBT 红黑树        | 红黑树比AVL的再平衡代价小      | 搜索 插入 删除 | 黑高+旋转/染色                        |
| B 树              | 磁盘/页式存储                  |                | 一个节点多个Key                       |
| B+ 树             | 数据库 sql用的                 | 范围查找       | 把B树的节点换成存外部指针             |
| Van Emde树        | 整数键                         |                | 整数宇宙结构递归分解                  |
| 最小生成树        | 图中如何连接所有点且总权重最小 |                | Kruskal/Prim                          |
| Huffman树         | 用树构造最优前缀编码           |                | 频率最低的不断合并                    |
| 划分树            | 静态序列的区间第k小            |                | 按值域递归划分                        |
| 动态树            | 动态森林上的路径操作           |                |                                       |
| KD树              | 多维空间搜索                   |                |                                       |
	

#### 二叉树
二叉树是没有什么序关系的树 它仅定义了: 最多两个孩子.

```rust
struct BinaryTree {
    root: Option<NonNull<Node>>,
    marker: PhantomData<Box<Node>>,
}
struct Node {
    value: i32,
    left: Option<NonNull<Node>>,
    right: Option<NonNull<Node>>,
}
```


因为完全没有其他要求 所以它的插入实现不唯一 而且**很可能退化为链表**.
##### 遍历
二叉树主要有4种遍历:

1. 前序(DFS): `parrent->left->right`
2. 中序(DFS): `left->parrent->right`
3. 后序(DFS): `left->right->parrent`
4. 层序(BFS): 一层层从左到右

- 前序中序后序遍历 区别就在于什么时候`res.push`:

```rust
impl BinaryTree {
    pub fn forward_iter(&self) -> Vec<i32> {
	let mut res = vec![];
	if let Some(root) = self.root {
	    forward_iter_node(Some(root),&mut res);
	}
	res
    }
}
pub fn forward_iter_node(node: Option<NonNull<Node>>,res: &mut Vec<i32>) {
    unsafe {
	if let Some(parent) = node {
	    let parent_ptr = parent.as_ptr();
	    // res.push((*parent_ptr).value); // 前序遍历放这里

	    if let Some(left) = (*parent_ptr).left {
		forward_iter_node(Some(left),res);
	    }
		// res.push((*parent_ptr).value); // 中序遍历放这里

	    if let Some(right) = (*parent_ptr).right {
		forward_iter_node(Some(right),res);
	    }
		// res.push((*parent_ptr).value); // 后序遍历放这里

	}
    }
}
```

- 层序BFS 所以不需要递归

```rust
impl BinaryTree{
    pub fn floor_iter(&self) -> Vec<i32> {
	let mut res = vec![];
	let mut queue = VecDeque::new();
	queue.push_back(self.root);
	while let Some(node) = queue.pop_front() {
	    unsafe {
		let node = node.unwrap();
		let node_ptr = node.as_ptr();
		res.push((*node_ptr).value);
		if let Some(l) = (*node_ptr).left {
		    let l_ptr = l.as_ptr();
		    queue.push_back(Some(l));
		}
		if let Some(r) = (*node_ptr).right {
		    let r_ptr = r.as_ptr();
		    queue.push_back(Some(r));
		}
	    }
	    
	}
	res
    }
}
```
#### 二叉搜索树BST
二叉搜索树是为了进行 **快速的查找**, 它在二叉树的基础上 额外的定义了:

$$
left < parrent < right
$$

所以假如要查询一个值, 最多只用比较 $O(logn)$次.

##### 插入
```rust
pub fn insert(&mut self,v:i32) {
	if let Some(node) = self.root {
	    unsafe {
		Self::insert_node(node,v);
	    }
	}
    }
    unsafe fn insert_node(mut node: NonNull<Node>,v: i32) {
	let node = node.as_mut();

	if v < node.value {
	    if let Some(left) = node.left {
		Self::insert_node(left,v);
	    } else {
		let new_node = Box::new(Node::new(v));
		
		let ptr = unsafe {NonNull::new_unchecked(Box::into_raw(new_node))};
		node.left = Some(ptr);
	    }
	} else if v > node.value {
	    if let Some(right) = node.right {
		Self::insert_node(right,v);
	    } else {
		let new_node = Box::new(Node::new(v));
		
		let ptr = unsafe {NonNull::new_unchecked(Box::into_raw(new_node))};
		node.right = Some(ptr);
	    }
	}
}
```

如果插入的元素一直越来越大 或者越来越小 那么显然的 会退化为链表 使得查找变成O(n).
##### 查找
```rust
pub fn print(&self) {
	let mut res = vec![];
	if let Some(root) = self.root {
	    Self::_print(root,&mut res);
	}
	println!("tree is : {:?}",res);
	
    }
    fn _print(node: NonNull<Node>,res: &mut Vec<i32>) {
	unsafe {
	    let val = (*node.as_ptr()).value;
	    res.push(val);

	    if let Some(left) = (*node.as_ptr()).left {
		Self::_print(left, res);
	    }

	    if let Some(right) = (*node.as_ptr()).right {
		Self::_print(right, res);
	    }
	}
	
    }
```
##### 删除
删除有4种情况

1. 删除节点没有左孩子和右孩子: 直接删除
2. 有左孩子没右孩子/有右孩子没左孩子: 用唯一的孩子替代
3. 有两个孩子: 找到左子树最大的节点替代
#### 平衡二叉树AVL
平衡二叉树就是为了解决 **退化成链表**的这个问题. AVL是加入了高度约束的BST.

所以它仍然满足 `left < parent < right`.

但是AVL额外要求: **任意节点的左右子树高度最多差1**.

定义平衡因子:

$$
BF(node) = height(left(node)) - height(right(node))
$$

那么 $BF(node) \in {-1,0,1}$

然后注意, Node需要记录树高了.

```rust
struct Node {
    value: i32,
    left: Option<NonNull<Node>>,
    right: Option<NonNull<Node>>,
	heigt: usize,
}
```

查找操作和BST一致.
##### 旋转
AVL的核心就是**通过旋转** 在不破坏BST中序顺序的情况下来降低树高.

当 BF(node) 大于等于 正负2的时候 需要旋转了.

旋转一共有4种情况.

1. LL: 右旋

```
      30
     /
    20
   /
  10
```

我们把30掰下来 **右旋30**

```
    20
   /  \
  10   30
```

2. RR

```
10
  \
   20
     \
      30
```

我们把10掰下来 **左旋10**

```
    20
   /  \
  10   30
```

3. LR

```
    30
   /
  10
    \
     20
```

我们把20掰上去 然后把30掰下来 **左旋10+右旋30**

```
    20
   /  \
  10   30
```

4. RL

```
10
  \
   30
   /
  20
```

我们把20掰上去 然后把10掰下来 **右旋20+左旋10**
##### TODO插入
与BST的区别在于: 插入后要更新height(这可以通过递归顺便完成) 与 BF. 然后通过BF判断我们需要进行LL LR或者其他的操作
#### 红黑树
红黑树是 AVL 在实际使用中的权衡后进行的改版.

它们都是 $O(logn)$的查找 插入与删除.

但是平均情况下 **红黑树的旋转次数会更少**.

**但是红黑树不是严格平衡的**.
##### 着色五性质
在RBT中 红黑树的每个节点规定为 **红色** 与 **黑色**. 空子树我们叫它NIL.

p红黑树有5条着色规定.

1. 每个节点是黑色或者红色
2. root是黑色
3. 所有的空子树NIL是黑色
4. 红色节点的两个子节点必须是黑色
5. 从任意节点出发 到其所有后代的空子树NIL的每条路径的黑色节点数相等

也就是说: 红色节点不可以**连续出现**.

那么一条路径上的红色节点的数量小于树高的一半.

我们令每条路径的黑色节点数量是m. 那么最长路径应该是: 红色节点隔一个黑色节点出现一个.

也就是说: 最长路径有 2m个节点. 最短路径 m个.

也就是说: **最长路径不会超过最短路径的2倍**

那么红黑树的树高是O(logn)
##### 插入与旋转
决策树
```
- 标记新节点为红色
  - 父节点黑: 结束
  - 父节点红
	- 叔节点红: 染红爷爷节点 父亲和叔叔节点染黑 然后到爷爷节点判断是否满足红黑树性质.
	- 叔节点黑: 旋转然后将旋转的节点的颜色对调
```

1. 插入新节点z 首先标记为红色. 因为红色不会破坏第5个性质.
2. 判断父节点. 若父节点是黑色 那么不需要旋转. 若父节点是红色 进入修复流程

修复流程(爷爷节点必然是黑色):

- 若叔节点(父亲的兄弟)是红色, 那么把爷爷节点染红 父亲和叔叔节点染黑 然后到爷爷节点再去判断是否不满足性质.
- 若叔节点是黑色, 那么就需要旋转与染色. 首先按照与AVL一模一样的方法旋转, 然后将旋转的节点的颜色对调.
##### 删除
决策树
```
- 只有左孩子/只有右孩子: 孩子代替这个节点然后变黑
- 没有孩子
  - 若这个节点是红色: 删除即可
  - 若它是黑色: 删除它然后把它标记为双黑节点
	- 兄弟是黑色
		- 兄弟至少一个红孩子: (LL,RR,LR,RL)旋转然后变色 此时能消除双黑
		- 兄弟孩子都是黑孩子: 兄弟变红 双黑标记上移
	- 兄弟是红色: 兄弟和父节点变色,父节点朝着双黑旋转 然后转换为双黑的兄弟是黑色的情况
```


要删除的节点只有两种情况:

1. 它有左孩子/它有右孩子: 只有可能是黑是父节点 红是子节点,因为如果黑是子节点 那么会违反性质5.

这种情况 直接删除它 然后用它的孩子替代 然后染黑即可.
2. 它没有孩子: 如果是红节点 直接删除. 如果是黑节点稍微要复杂一些.

黑节点的话 删除它后 会破坏性质5.

首先它会变成NIL黑, 那么我们引入一个概念叫 **双黑节点**. 因为只有这个NIL节点是两重黑 那么才能满足性质5. 接下来我们需要想办法消除这个双黑节点.

为了消除这个双黑节点 我们需要去看它的兄弟节点.

首先如果它的兄弟节点是黑色: 

- 如果兄弟至少有一个红孩子: 我们判断它的远侧孩子. 也就是离双黑节点远一点的那个.

如果远的是红色 那么对父节点进行一次旋转然后着色. 如果远的是黑色 那么先把兄弟节点旋转 然后旋转父节点两次旋转.

- 如果兄弟的孩子都是黑: 兄弟变红 双黑状态上移. 然后重复这个过程看看能不能满足上面那个条件再调整.

如果它的兄弟节点是红色: 兄弟和父亲节点变色 然后父节点朝着双黑节点方向旋转 然后再判断双黑节点的兄弟 此时会满足它的兄弟是黑色的情况 再去调整.
#### 二叉堆BinaryTree
二叉堆是一个 **优先队列**, 而且是一颗 **完全二叉树**.

因为它是一颗完全二叉树 所以它可以直接用**数组**表示.

## 数组操作算法
### 绝对众数算法
绝对众数算法就是计算数组里的 **出现最多的元素**.

出现最多的元素还有个特征 就是数量大于$\frac{n}{2}$.

这个算法存在一个时间复杂度`O(n)` 空间复杂度`O(1)`的算法: Boyer-Moore投票算法.

Boyer-Moore算法的核心是: 不同的元素互相抵消 因为绝对众数超过一半 所以最终一定留下.

```rust
impl Solution {
    pub fn majority_element(nums: Vec<i32>) -> i32 {
	let mut candidate = 0;
	let mut cnt = 0;
	for num in nums {
	    if cnt == 0 {
		candidate = num;
	    }
	    if num == candidate {
		cnt += 1;
	    } else {
		cnt -= 1;
	    }
	}
        candidate
    }
}

```
### 旋转算法
我们一般使用三次旋转算法 使用`O(n)`时间, `O(1)`空间.

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


## 搜索算法
用于在状态空间中找到最优解.

| 算法     | 要求与用途 | 时间复杂度 | 空间复杂度 |
|----------|------------|------------|------------|
| 二分搜索 | 有序序列   | O(logn)    | O(1)       |
|      |        |            |            |
### 二分搜索
利用序列 **有序** 的性质 通过对搜索的 左右边界进行二分 使得在 O(logn)时间可以求解.

我们这里采用linux内核的二分搜索实现.

- 这里通过 `num >> 1` 进行二分 避免了除法
- `base`维护左边的边界, `num`维护剩余元素数量
- `num--` 代表把pivot的当前元素去掉. 也就是说 每次缩小的范围是**前闭后开**区间, `[base,pivot)`
```c
static __always_inline
void *__inline_bsearch(const void *key, const void *base, size_t num, size_t size, cmp_func_t cmp)
{
	const char *pivot;
	int result;

	while (num > 0) {
		pivot = base + (num >> 1) * size;
		result = cmp(key, pivot);

		if (result == 0)
			return (void *)pivot;

		if (result > 0) {
			base = pivot + size;
			num--;
		}
		num >>= 1;
	}

	return NULL;
}
```

下面是rust写法
```rust
#[inline]
pub fn bsearch<T, F>(slice: &[T], key: &T, cmp: F) -> Result<usize, usize>
where
    F: Fn(&T, &T) -> Ordering,
{
    let mut num = slice.len();
    let mut base = 0;
    while num > 0 {
        let pivot = base + (num >> 1);
        match cmp(key, &slice[pivot]) {
            Ordering::Equal => {
                return Ok(pivot);
            }
            Ordering::Greater => {
                base = pivot + 1;
                num -= 1;
            }
            _ => {}
        }
        num >>= 1;
    }
    Err(base)
}

```
## 调度器算法
调度器是操作系统最重要的算法之一,用于进程的调度.

### Linux内核
Linux内核的调度器内容请看linux章节的调度器章节.
### 异步执行器
异步执行器的算法和操作系统的不太一样.

异步执行器主要是为了让 **任务在某个需要操作系统 或者 交给外部做的事件的时候 让出资源**.

比如一个进程需要 **等待网络连接** **等待磁盘写入**, 那么它们可以被挂起 在这个时候.


下面是很多不同异步运行时的区别

| 运行时     | 调度模型      | 调度单位          | 机制                                    |
|------------|---------------|-------------------|-----------------------------------------|
| rust tokio | work stealing | async task/future | 每个worker的本地队列/全局队列/LIFO slot |
| Go         | G-M-P         | Goroutine         | 本地运行队列 全局队列 **抢占**          |


#### Tokio
Tokio是rust最著名的异步运行时.

##### 主循环
定义于 `runtime/scheduler/multi_thread/worker.rs`

1. 检查LIFO slot
2. 检查local queue
3. 适时检查global queue
4. 没有任务时尝试work stealing
5. 找到任务后 poll(task)

##### queue
queue的数据结构是**环形队列** 容量256.

但是这个local队列是可以被其他的woker拿走的 所以设计是**原子**的.

##### work stealing
负载均衡.

也就是一个worker没有任务的时候从其他woker拿任务来.
## 图TODO
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
### 最长重复字符的子串
```rust
fn max_substr(s: &str) -> usize {
    if s.len() == 0 {return 0;}
    let s = s.as_bytes();
    let (mut mx,mut l) = (1,0);
    for r in 1..s.len() {
	if s[r] != s[r-1] {
	    l = r;
	} else {
	    mx = mx.max(r - l + 1);
	}
    }
    mx
}
```
### 字符串匹配算法
#### KMP
KMP算法是先预处理一个`pattern`数组 它记录了: 如果匹配到这没匹配成功 就直接跳转相应的位置.

比如
```
str:
0 1 2 3 4 5 6
a b a b a b c

pattern:
0 1 2 3 4
a b a b c
```

其实 当第四个位置 a与c不匹配的时候 我们不需要在这个位置把pattern回退到0 我们可以直接让它回退到2,

因为 如果是c不匹配 那么前面的`abab`是**匹配的**, 在c**前面**已经有两个ab, 而**开头**也有两个ab, 所以这个ab是不用重复匹配的.

这个从头开始的ab叫**前缀** 从c前面的ab叫**后缀**.

KMP算法就是通过 找到 **最长的 相等的前缀与后缀** 这样就可以不用回退j到开头了.

最长公共前后缀算法叫LPS. 我们求出pattern的LPS数组 就求出了匹配失败的时候 j回退的位置.

##### LPS
若 `s[i] == s[j]` 就给`j + 1` 因为最长LPS 可以变长.

若 不等于 那么j回退到lps[j-1] 然后继续看看能不能变长.
```rust
pub fn lps(s: &[u8]) -> Vec<usize> {
    let mut lps = vec![0;s.len()];
    let mut j = 0;

    for i in 1..s.len() {
	while j > 0 && s[i] != s[j] {
	    j = lps[j-1];
	}
	if s[i] == s[j] {j += 1;}
	lps[i] = j;
    }
    lps
}
```

在获得了LPS后 我们可以实现KMP算法了

```rust
pub fn kmp(s: &str, p: &str) -> Option<usize> {
    let (s, p) = (s.as_bytes(), p.as_bytes());
    let lps = lps(p);
    let mut j = 0;

    for i in 0..s.len() {
		// 不匹配 根据j = lps[j-1]回退j
        while j > 0 && s[i] != p[j] {
            j = lps[j - 1];
        }
		// 直到匹配 或者 j = 0为止.
        if s[i] == p[j] {
            j += 1;
        }
        if j == p.len() {
            return Some(i + 1 - p.len());
        }
    }
    None
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
### GF(2)伽罗瓦域
GF(2) 只有**两个**元素

$$
GF(2) = {0,1}
$$

则有
- 加法单位元: 0
- 乘法单位元: 1
- 加法逆元: 1是1 0是0
- 加法: 整数加法后对2取余 也就是XOR
- 乘法: 也就是AND 因为 仅 $1 \times 1 = 0$

所以实际上 **二进制串** 是 $x \in GF(2)$ 的**向量空间**

我们记元素为二进制的长为n的向量为 $GF(2)^n$
## 二进制
### 2的幂
如果一个数是2的幂 那么它的二进制最高位是1 其他位数是0. 也就是说:

$$
n & (n-1) = 0
$$

