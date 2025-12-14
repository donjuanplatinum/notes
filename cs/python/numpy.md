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
- `T`: 转置
### 方法
#### 变形与操作
- `reshape(shape)`: 变形
- `flatten()`: 展平一维
- `ravel()`: 返回视图
- `squeeze()`: 去掉维度为1的轴
#### 维度统计
- `argmax(dim)`: 给定维度上最大值的索引
- `argmin(dim)`: 同理
- `sum(dim)`: 给定维度求和
- `mean(dim)`: 给定维度的均值
- `var(dim)`: 给定维度的方差
- `std(dim)`: 给定维度的标准差
- `prod(dim)`: 给定维度的积

#### 合并
- `concat(arrays,axis)`: 沿axis轴合并 **数组维度必须匹配除了拼接轴以外的所有维度**
- `stack(arrays,axis)`: 沿axis轴合并 增加一个新的维度 **所有数组形状必须完全相同**
- `block(arrays)`: 块状拼接 **对应拼接方向上尺寸匹配**
#### 快速傅立叶变换
一般用scipy.fft
#### 线性代数
- `dot`: 点积
- `outer`: 外积
- `matmul`: 矩阵乘法
- `kron`: 科洛内克积
#### 数学
- `sin/cos/tan/arcsin/arccos/arctan`: 三角函数
- `degrees/radians`: 角度弧度的转换
- `sinh/cosh/tanh/arcsinh/arccosh/arctanh`: 双曲三角函数
- `exp`: e的指数
- `log`: 自然对数
## numpy 
numpy主模块
### 常量
- `e`: 2.718...
- `euler_gamma`: 0.577.. 就是调和级数和自然对数的差的极限
- `inf`: 无穷大
- `nan`: NaN
- `pi`: 圆周率
### ndarray的构建函数
- `empty(shape)`: 按照形状创建数组
- `empty_like(array)`: 按照array的形状和类型创建空数组
- `eye(n,m,k=0)`: 返回一个n*m对角线矩阵(对角线为1) k为对角线偏移
- `identity(n)`: n*n单位矩阵
- `ones(shape)`: 全1的矩阵
- `ones_like(array)`: 和array形状类型一样的全1矩阵
- `zeros(shape)`: 全0矩阵
- `full(shape,value)`: 全是value矩阵
- `arange(start,stop)`: 起点到终点 公差为1的向量
- `linspace(start,end,num)`: 在start到end之间 有num个**均匀**的点的向量

