# Numpy
Python的数学库 包含了高端的数组操作 是很多其他库的底层数据形式: torch,matplotlib,pandas...

## ndarray
ndarray是Numopy最重要的对象

ndarray的内容为:
- 指向数据的指针
- 数据类型
- shape形状
- stride

举个例子 假设我有一个1055行 1024列的数组 它的shape为(1055,1024)

实际上它的存储是线性的 那么相当于一个线性的数组
```
[
[a,..,1024个],
[b,..,1024个],
..1055个
]
```
所以它**沿着**第0维移动 也就是同一行移动一个 要经过一个元素

所以strides[0] = 1 (当然这个是字节 1*数据类型的长度)

而沿着第1维移动 就是从第一列到第二列 需要一次经过1024个

所以strides(1*len,1024*len)

### 成员
- `ndim`: 数组的秩 即数组的维度或轴的数量
- `shape`: 数组的维度
- `size`: 元素总数
- `dtype`: 内部dtype类型
- `itemsize`: 内部元素的大小
- `flags`: 内存布局信息
- `data`: 内部实际存储的缓冲区
### 方法
- `reshape(shape)`: 变形
- `flatten()`: 展平一维
- `ravel()`: 返回视图
- `squeeze()`: 去掉维度为1的轴
- `linspace(start,end,num)`: 在start到end之间 生成num个均匀的点的ndarray
