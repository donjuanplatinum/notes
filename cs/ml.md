# ML
## 神经网络
神经网络的本质是

`神经网络是一个通过优化学习参数，以逼近（或拟合）任意复杂函数的通用非线性映射器`

可以把神经网络看作一种把输入空间映射到输出空间的几何变换。

每一层线性变换 + 非线性激活，使数据在高维空间中逐渐变得“线性可分”。

- 线性层负责旋转 拉伸 平移
- 激活函数负责弯曲空间 使模型表达非线性边界

**那为什么不用其他数学方法逼近?**
数学里面有那么多逼近函数的方式: Taylor展开 Lagrange插值 傅立叶....

其他数学方法的泛化能力都非常的弱 比如逼近sinx. 拉格朗日插值就会在边界震荡 而神经网络可很好的泛化
## Tensor
张量

`!注意 与物理学中的张量不一样`

张量在存储结构上来说就是一个多维数组 是对矩阵的更高维度的推广

张量的存储包含了张量的形状 张量的实际内容
### 形状
n维张量的形状是一个`n个元素的元组`

- `shape(a)` 这是一个有a个元素的向量
- `shape(a,b)` 这是一个a行b列矩阵
- `shape(a,b,c)` 这是一个a块b行c列矩阵 相当于有两个shape(b,c)

在CNN中 通常使用4维张量: `shape(n,c,h,w)`

其中n为batch c为channels h为high w为weight

比如32张64*64的RGB图片

$$
shape = (32,3,64,64)
$$

### 张量形状的底层存储
张量是行优先原则

以CNN为例

```
[
  [  # 第1张图片
	# R通道
    [
	# 2*2矩阵
	[a,b],
     [c,d]
	 ],
    # G通道
    [[e,f],
     [g,h]],
	 # B 通道
	 [[m,b],
	 [p,q]],
  ],
...
]

```

然而在计算机中存储为线性的结构[a,b,c,d,e,f,g,h,m,b,p,q....]

所以需要去索引
#### 索引
我们只需要一个 stride 即一个步幅 就能精确索引了

shape=(a,b,c,d) 而stride[i] 会告诉你 在i维上走1步 实际上是在线性数组中走几步

我们不难的发现
```
stride[3] = 1
stride[2] = d
stride[1] = c * d
stride[0] = b * c * d
```

所以假设我需要访问元素(n,c,h,w) -> `offset = n * 1 + c * d + h * (c * d) + w * (b * c * d)`
### 矩阵乘积形状判断
当且仅当前一个矩阵的列数n等于后一个矩阵的行数m时 两个矩阵的乘积为m*p矩阵

$$
A_{mxn}  B_{nxp} = C_{mxp}
$$
### 正态分布
在初始化时 经常使用正态分布 因为正态分布`更自然而稳定 多数聚集在0附近 少量较大值`
```rust
// 以0.0为均值 0.02为标准差 创建input_dim行 hidden_dim列矩阵
let tensor = Tensor::randn(0.0,0.02,(input_dim,hidden_dim))?;
```
### 哈达玛乘积
对于两个具有相同维度的矩阵,它们的哈达玛乘积为逐元素相乘

$$
(A \circ B)_{ij} = A_{ij}  B_{ij}
$$
### 点积
点积反应的意义是: 张量x在y方向上的投影再与y的乘积, 能够反应两个张量的`相似度`

*点积越小 相似度越小*
## 卷积
上卷积在深度学习中 可理解为特征提取

可以理解为用卷积核在输入的矩阵上滑动. 将重合的部分相乘然后分别相加 求和的结果放到新的矩阵 (即为 输入的特征和卷积核的特征进行相似度的匹配)

```
矩阵     卷积核        
1 2 3     2 -1
4 5 6     1  2       
7 8 9

滑动
1 2   2 -1   ->  1 * 2 + -1 * 2 + 4 * 1 + 5 * 2
4 5   1  2

```



一个 m * n 的矩阵 与 a * b的卷积核卷积 得到一个 (m - a + 1) * ( n - b + 1)的矩阵

即

$$
输出矩阵的高 = \frac{源矩阵的高 - 卷积核的高 + 2 填充}{步长} + 1
$$

$$
输出矩阵的宽 = \frac{源矩阵的宽 - 卷积核的宽 + 2 填充}{步长} + 1
$$

即28 * 28像素 在3 * 3卷积后 得到 26*26的矩阵
### 离散卷积

$$
y_t = \sum_{k=0}^{t} h_k x_{t-k}
$$

卷积性质
- 线性性质
- 平移不变性

#### 与傅立叶变换

$$
y = h * x
$$

$$
F(y) = F(h) \circ F(x)
$$

即 h和x的卷积的傅立叶变换 等于h的傅立叶变换 和x傅立叶变换的哈达玛乘积
### 卷积核
在神经网络中 卷积核一开始是随机的 而在模型训练的过程中通过反向传播等进行更新.

`所以模型训练的过程之一可以说就是在更新和确定卷积核`

不同卷积核可提取出不同的特征: 如类似Laplace的卷积核用二阶导近似算子检测灰度突变位置  而类似Guass的卷积核抑制噪声，高频信息被压制。

## 转置卷积
转置卷积是卷积的逆过程 基于较小的特征图 生成较大的特征图
## 池化
池化是对卷积后结果的一次"抓重点"

池化和卷积一样 也有一个池化核 同时也是在矩阵上滑动.

区别是池化核的矩阵只是一个框框 一个形状 里面没有任何特征.

池化的过程是这样的: `在经过卷积后 得到了特征矩阵. 我们使用池化核框框在这个矩阵上滑动 每次取这个框框里的最大值放到新的矩阵里`

然后滑完后得到的新的矩阵就是池化结果

我们不难的发现 一个m*n 矩阵 与 a * b的池化核池化 得到一个 (((m - a) / a)的向下取整+1) * (((n - b ) / b)的向下取整 + 1)

池化的公式

$$
输出矩阵的高 = \frac{原矩阵的高 + 2 * 填充 - 池化核的高}{步长} + 1
$$
## 全连接层
神经网络的分类器

全连接层输出对分类的`预测分数logits`

logits的张量为: `shape(batch_size,n)`


$output = W x ^ T + b$

其中x为图片展平后的向量 W为权重矩阵shape[out_size,in_size] b为偏置向量shape[out_size]


我们知道 输入的向量是一个1 * in_size形状的矩阵

根据矩阵的乘法 我们有

$$
W_{nxb} x_{1xn} = out_{1xb}
$$


全连接层的输入张量是二维的`shape(batch_size,n)`


在初始时 W和b是随机的(形状不随机) 而在模型训练过程中通过反向传播等进行更新




`所以模型训练的过程之一可以说就是在更新和确定全连接层参数`


在Mnist CNN中 使用了两个全连接层


第一层linear(in_dim,out_dim): in_dim为池化后的张量shape(num,dim)中的dim out_dim为第一次粗分类



而第二层linear(out_dim,out_dim2): 把第一层的分类结果分类为最后的out_dim2
## 损失函数

$$
L(x_i,y_i,\theta)
$$

其中
- x_i: 第i个输入样本
- y_i: 这个样本的标签
- $\theta$: 模型参数
- L: 损失函数
### nll
负对数似然损失

它希望模型给正确类别分配的概率越高越好，错的越低越好。

真实标签是索引y

$$
NLLLose(p,y) = - log(p_{y})
$$

即取出真实类别对应的预测概率$p_{y}$

与交叉熵损失的联系

$$
CrossEntropyLoss(z,y) = NLLLoss(log_softmax(z),y)
$$

### cross_entropy
交叉熵 用于 分类任务 的常用损失函数

它衡量的是 真实标签与 预测概率分布 之间的差异 差异越小 模型性能越好

如果模型正确预测了类别，损失会小（概率接近 1，log(1) = 0）。

如果模型错误预测了类别，损失会大（概率接近 0，log(0) 会趋近负无穷）

假设我们有一个n分类问题 给定一个真实标签的分布p和概率函数(一般是softmax)输出的概率分布q 满足:

$$
H(p,q) = - \sum_{i=1}^{n} p_{i} log{q_{i}}
$$

- $p_{i}$是真实标签的概率分布 通常是一个one-hot向量(即除了真实的标签的数组下标为1 其他为0)
- $q_{i}$是模型预测的概率分布 通常是通过softmax得到的概率分布
### 均方差损失

$$
L = \frac{1}{n} \sum_{i=1}^{n}(y_i - \hat{y_i})^2
$$

其中
- $y_i$是真实值
- $\hat{y_i}$是模型预测值
- $n$是样本数量

在这种情况下，损失函数度量的是预测值与真实值之间的差异，模型的目标是最小化这个损失。

## 梯度下降
通过沿着损失函数的梯度的反方向更新参数来减少损失函数的值

$$
\theta = \theta - \eta \cdot \frac{\partial L}{\partial \theta}
$$

其中
- $\theta$是需要更新的参数 比如权重 偏置
- $\eta$是学习率
- $\frac{\partial L}{\partial \theta}$是损失函数关于参数的梯度


### 随机梯度下降
在每一次更新中随机抽取样本来梯度下降 可节省内存
## 学习率
学习率控制着模型在训练过程中每次参数更新的步长大小 即在使用梯度下降（或其变种）更新神经网络参数时 调整的幅度 所以学习率极大影响着梯度下降核反向传播的过程


## 反向传播
深度学习的可行性建立在 *每个参数的输出对损失的可导性*
在拿到前向传播得到的损失函数后 通过损失函数对神经网络的卷积层或全连接层的参数求偏导 一层层的使用链式法则偏导过去 

然后根据学习率 来更新参数的值

这就是反向传播
## 数据集
在训练模型时 我们会把数据分成两到三个部分
| 名字             | 缩写           | 意义                                              |
|------------------|----------------|---------------------------------------------------|
| 训练集           | training set   | 学习的样本 就是实际训练的数据                     |
| 验证集(optional) | validation set | 用来在训练中`调参`或`防止过拟合`的样本 不用于训练 |
| 测试集           | test set       | 评估的样本 不用于训练                                                  |
训练集不必多说

### 验证集
验证集可以`帮助调整模型结构、超参数`

超参数的调整一般不会使用训练集来判断 因为如果你用训练集评估超参数，那么模型会倾向于“记住”训练集的规律，而不是真实的规律。


### 数据集处理
在训练前 是需要对数据集进行预处理的

比如图像切割,图像转化为张量,图像标准化
#### 调参
一般在每个epoch后在验证集上评估准确率或损失

- 若验证集准确率不升反降 → 说明学习率太高或过拟合；
- 若验证集损失下降 → 模型正在学习；
- 若验证集损失稳定 → 可以提前停止训练（early stopping）

#### 防止过拟合
验证集可以帮我们实时监控模型的泛化性能。

常见的做法
- Early stopping（提前停止）： 当验证集损失连续几轮不再下降时 就停止训练
- 学习率调整（Learning Rate Scheduler）： 如果验证集性能变差 → 降低学习率。
- 正则化强度调整（Dropout, Weight Decay）: 通过验证集效果判断是否正则化太强或太弱。
## 过拟合
模型在训练集上表现非常好，但在没见过的数据（测试或验证集）上表现很差。
即：它“背题”了，没有真正学会规律。

当验证集损失开始上升而训练集仍下降时，就是过拟合的信号。
## 正则化
在损失函数中加“惩罚项” 给模型加一点「约束」，让它不要太依赖训练集的细节，而去学更通用的规律。

普通的损失函数

$$
L = Loss(data,model)
$$

正则化后的损失函数

$$
L = Loss(data,model) + \lambda x Regularization term
$$

- $\lambda$: 正则化强度(超参数)
- Regulartization term: 惩罚模型太复杂的部分
## 超参数
超参数是我们需要手动调整的值 重要影响模型的训练

- 学习率
- 批大小
- 网络层数
- 卷积核大小
- 随机失活Dropout比例
- 优化器类型(Adam/SGD)
- 正则化系数(weight_decay)
- 训练轮数(epoch)
## 随机失活
DropOut

在训练时随机“丢掉”一部分神经元（不参与前向传播和反向传播）

可使每次训练让网络“看”的神经元子集不同，防止不同神经元之间过度依赖。
## 数据增强
data augmentation

对输入图像做随机旋转、裁剪、翻转等，让模型“见多识广”，不过拟合。
## 优化器
优化器决定模型的参数是如何根据损失函数更新

优化器是负责更新模型参数的算法

### SGD
随机梯度下降

有时会加入动量 来使下降更平滑

### Adam
最常用的优化器之一

- 每个参数都自动调整自己的学习率；
- 保留历史梯度的均值和方差，更新更平滑；
- 通常训练速度更快、收敛效果更稳定。
### RMSProp
适合非平稳目标(如RNN)

和 Adam 类似，也会自动缩放学习率，但没有动量项

### Adagrad
让稀疏特征更新更快

问题：后期学习率会变得太小，不再学习。

### AdamW
Adam的改进版 加入正则化

目前非常推荐在 Transformer 和 CNN 中使用。
## 概率
将输入转换为概率分布

需要使用概率函数进行输出
### softmax
常见用于多分类问题的最后一层 将模型输出的logits转换为概率分布

常与softmax_crossentropy搭配
特点:
- 使得每个元素表示`对应类别的概率` 且总和为1
- 所有输出压缩到[0,1]

给定一个张良 $z = [ z_{1}, z_{2}, ..., z_{n}]$ 则soft将$z_{i}$会转换为类别概率$p_{i}$

$$
p_{i} = \frac{e^{z_{i}}}{\sum_{j=1}^{n} e^{z_{j}}}
$$

### log_softmax
log_softmax是softmax函数的对数版本 通常用于分类任务的最后一层输出

常与负对数似然损失(NLLLoss)配合 将分类的logits转换为对数概率

log_softmax输出的对数概率小于等于0
$$
log_softmax(z_{i}) = log(\frac{e^{z_{i}}}{\sum_{j=1}^{n} e^{z_{j}}})
$$

化简为

$$
log_softmax(z_{i}) = z_{i} - log(\sum_{j=1}^{n} e ^{z_{j}})
$$

## 激活函数
因为在神经网络中 各种变换都是矩阵间的线性变换 它变来变去永远是直线 那么它永远无法表达曲线

加入非线性的激活函数后 直线会变为曲线 能更好的去逼近曲线
### ReLU

$$
f(x) = max(0,x)
$$

常用于CNN

优点
- 计算简单 收敛块
- 避免梯度消失 对正数 导数恒为1
- 稀疏激活 很多神经元输出0 有正则化效果

### tanh

$$
tanh(x) = \frac{e^x - e^{-x}}{e^x + e^{-x}}
$$

常用于RNN

输出范围(-1,1)

优点
- 平滑连续
- 输出有符号 可表示正向记忆 负向记忆

### sigmoid

$$
\sigma(x) = \frac{1}{1+e^{-x}}
$$

s形曲线 输入大时饱和于1 小于0时饱和于0 常用于门控LSTM
### softplus

## tokenizer
实际上就是一个KV表 但是加入了一些适用于自然语言处理的映射算法

将原始的文本切成一系列token 再把每个token映射为ID
```
输入句子: "I love you"
↓ token
分词: ["I", "love", "you"]
↓ token_id
映射ID: [101, 2347, 872]

```

但是tokenizer实际上会加入更多的操作 比如unicode规范 填充一些特殊的tokenizer自己的标记字符等

而Tokenizer也是`需要训练`的 因为分词方法需要找到最优的
token表 通常用BPE或Unigram分词

在deepseekV3中 一个token的向量为7168维

- BPE 从语料中统计最常见的字符组合 并不断合并
- WordPiece 用似然估计挑选最优子词集合
- Unigram/SentencePiece 用概率模型选出最优子词表

## embedding
将tokenizer得到的token_id转换为一维张量(向量)

假设有几个token"apple" "banana" "redpen"

而向量的方向为(颜色,种类)

则
- apple = (红,水果) 
- banana = (黄,水果)
- redpen = (红,文具)

则apple - 水果 + 文具 $\approx$ 红笔

再比如相似的词之间的向量内积要小以表示相似

通常embedding是需要训练的 放在模型的一层中 通过反向传播更新
### RoPE
Rotary Embedding 旋转嵌入

是一种特殊的位置编码方法 相较于传统的sin/cos更能优雅的将位置信息融合进注意力的QK

原始的PE是把位置编码直接`加法`加入到embedding中

这样会使之变为`绝对位置` 不能直接知道token间的相对距离 以及序列更长时 泛化能力变差

RoPE是使用`旋转`来在向量空间表达位置信息

传统的注意力: $score_ij = q^T_i k_j$

RoPE的注意力: $score_ij = (R_{\theta(i)} q_i)^T (R_{\theta(j) k_j})$

其中$R_{\theta(p)}$是旋转矩阵 对每个位置p进行不同的角度旋转

- 每个位置p有不同的相位
- 两个token的相对位置i-j会反应在旋转角度差$\theta(i-j)$
- 注意力得分自然包含了相对位置信息
#### 原理
假设embedding维度为d 我们把两个维度当成一个二维平面$(q_2k,q_{2k+1})$

其中旋转角度: $\theta_p = p / 10000^{2k/d}$


## CNN
卷积神经网络

自动提取数据的空间特征 用于分类 检测分割等任务

```
输入图像------->张量(shape[batch_size,channels,high,weight]) ------> 卷积层 ----> 激活函数---->池化

----->经过多个这样的卷积+激活+池化----->展平为二维张量(shape[batch_size,channels*high*weight])----->全连接层------>激活------->经过多个全连接层+激活----->最后一个全连接层


------>转换为概率输出
```
### MNIST实现

CNN定义
```rust
pub struct MnistCnn{
    conv1:  Conv2d, // 卷积层1
    conv2:  Conv2d, // 卷积层2
    fc1: Linear, // 全连接层1
    fc2: Linear, // 全连接层2
}
```

构造函数
```rust
pub fn new(vb: VarBuilder) -> Result<Self>{
	// 加入padding填充以防止边缘特征无法提取
	let convdefault = Conv2dConfig{
	    padding: 1,
	    ..Default::default()
	}; 
	// 第一层输入为(channels:1,out_channels:32,kernel_size:3)
	let conv1 = conv2d(1,32,3,convdefault,vb.pp("c1"))?;
	// 第二层输入为(channels:32,out_channels:64,kernel_size:3)
	let conv2 = conv2d(32,64,3,convdefault,vb.pp("c2"))?;
	// 第二个卷积层的输出经过展平后输入到全连接层 被输出为128个分类
	let fc1 = linear(64*7*7,128,vb.pp("fc1"))?;
	// 将第一个全连接层输出的128个分类输出成最后10个分类
	let fc2 = linear(128,10,vb.pp("fc2"))?;
	Ok(Self{
	    conv1,
	    conv2,
	    fc1,
	    fc2,
	})
    }
```

forward过程
```rust
    fn forward(&self, xs: &Tensor) -> candle_core::Result<Tensor> {
		// batch_size为输入张量的第一个维度的大小 shape(batch_size,channels,h,w)
        let batch_size = xs.dim(0)?; 
		// 因为数据集的张量是(batch_size,n) 所以要变形张量
        let xs = xs.reshape((batch_size, 1, 28, 28))?;
        Ok(xs
		// 第一个卷积层
            .apply(&self.conv1)?
			// 激活
            .relu()?
			// 最大池化
            .max_pool2d(2)?
			// 第二个卷积层
            .apply(&self.conv2)?
			// 激活
            .relu()?
			// 最大池化
            .max_pool2d(2)?
			// 从第二个维度展平到最后一个维度
            .flatten_from(1)?
			// 第一个全连接层
            .apply(&self.fc1)?
			// 激活
            .relu()?
			// 第二个全连接层
            .apply(&self.fc2)?)
    }
```

训练
```rust
	// 构造参数集合Varmap和VarBuilder 后续反向传播时会更新这里的参数
    let vm = VarMap::new(); 
    let vb = VarBuilder::from_varmap(&vm,DType::F32,&Device::Cpu); 
	
	
	// 给模型输入参数
	let model = MnistCnn::new(vb.clone())?;
	
	// 反向传播用的优化器
	let mut optim = AdamW::new_lr(vm.all_vars(),learning_rate)?;
	
	// 数据集导入
	let datasets = vision::mnist::load()?;
	
	// 数据集图片张量变形为(batch_size,channels,h,w)
	let (train_images,test_images) = (datasets.train_images.reshape((60000,1,28,28))?,
	
	// 转换U8为F32
	let train_images = train_images.to_dtype(DType::F32)?;
    let test_images = test_images.to_dtype(DType::F32)?;
	
	// 标签转换为I64
	let train_labels = datasets.train_labels.to_dtype(DType::I64)?;
	let test_labels = datasets.test_labels.to_dtype(DType::I64)?;
	
	// 训练集的图片数量
	let train_image_nums = train_images.dim(0)?;
	
	// 批次数 = 图片数量 / 一批的图片数量
	let batches_num = train_image_size / batch_size;
	
	// 构造一个存放索引的向量
	let mut batch_indices = (0..batches_num).collect::<Vec<usize>>();

// 训练epochs轮
for epoch in 0..epochs{
	// 损失总和
	let mut sum_loss = 0f32;
	// 打乱索引的顺序 防止模型学习顺序(刷题化)
	batch_indices.shuffle(&mut thread_rng());
	// 一个batch_size为一组开始训练
	for batch_index in batch_indices.iter() {
		// 沿着train_images的第0维的batch_index * batch_size取出大小为batch_size的子张量
		// 第0维是图片维度 所以相当于从图片里面取出了batch_size张
	    let train_images = train_images.narrow(0,batch_index * batch_size,batch_size)?;
	    let train_labels = train_labels.narrow(0,batch_index*batch_size,batch_size)?;
		
		// 正向传播得到logtis分数
	    let logits = model.forward(&train_images).expect("训练集forward失败");
	    // 从正向传播的结果和实际的labels中计算损失函数
	    let loss = loss::cross_entropy(&logits,&train_labels)?;
		
		// 利用损失函数反向传播更新参数
	    optim.backward_step(&loss)?;
		// 累加损失
	    sum_loss += loss.to_scalar::<f32>()?;
	    
	}
	// 平均损失
	let average_loss = sum_loss / batches_num as f32;
	// 从测试集正向传播
	let test_logits = model.forward(&test_images)?;
	// 预测结果 并将概率最大的视为结果 
	let pred = test_logits.argmax(D::Minus1)?.to_dtype(DType::I64)?;
	
	// 将正向传播的结果与实际的结果比较 获得正确的预测的数量
	let sum_ok = pred.eq(&test_labels)?.to_dtype(DType::F32)?.sum_all()?.to_scalar::<f32>()?;
	// 准确率 = 正确预测的数量 / 总数量
	let test_acc = sum_ok as f32  / test_labels.dims1()? as f32;
	println!("{epoch:4} train loss {:8.5} test acc: {:5.2}%",average_loss,100. * test_acc);

	vm.save(format!("./model.safetensors-{}",epoch))?;
    }
```
## RNN
循环神经网络

处理序列数据，能够捕捉时间序列或有序数据的动态信息，能够处理序列数据，如文本、时间序列或音频

RNN 的关键特性是其能够保持隐状态（hidden state），使得网络能够记住先前时间步的信息，这对于处理序列数据至关重要。

```
输入x1张量(shape[1,in_size]) 计算隐藏状态--------->  h1(shape[1,hidden_dim])  计算全连接层------------> y1(shape[out_dim]) ------------------->  h2------------> y2 ......------> yn
		                                             
```



$w_x$的形状为shape([hidden_size,input_size]) 

注意 RNN的所有时间步的W,b是相同的
### 超参数
- hiddem_dim: 隐藏层维度越大 记忆越大 但运算速度更慢 更容易过拟合
- output_dim: 模型最终的输出大小 例如词汇表大小 情感分类 
### 输入张量
其中 输入x的形状为shape([seq_len,batch_size,input_dim])  

seq_len为序列长度 即RNN的时间步 循环的次数

batch_size为批大小

input_dim为每个时间步输入向量的维度

形象的比喻是 每句话seq_len个词 每个词input_dim维 每次输入batch句话
### 工作机制
1. 接收当前输入$x_t$和前一时刻的隐藏状态$h_{t-1}$
2. 计算新的隐藏状态
3. 产生输出

### 与传统的FNN
在传统的神经网络中 是不会管上下文的,比如苹果和苹果公司的苹果. 在全连接层输出后苹果的label是公司还是水果

完全取决于训练集谁的label多 所以一个词有多个含义在传统的NN中无法辨别.

而在RNN中 RNN会记住前面序列的信息 可达到上下文信息理解的效果


### 隐藏状态
这是RNN能记住前面序列信息 和 理解上下文的关键

隐藏状态为$h_{t}$ 隐藏层的维度为`hidden_dim` 隐藏层维度是决定模型性能的重要参数


$$
h_{t} = f(  W_{x} x_{t} +   W_{h} h_{t-1} + b)
$$

其中
- $x_t$: 当前输入
- $h_{t-1}$: 上一次的隐藏状态
- $f$: 激活函数
- $W_x$: 输入权重矩阵 处理输入$x_t$
- $W_h$: 隐藏状态权重矩阵 处理前一个隐藏状态$h_{t-1}$
- $b$: 偏置

而$W_x W_h b$就是反向传播更新的参数



### 输出
$y_t = g(W_{hy} h_t + c)$

其中g为激活函数

而$W_y$和c就是反向传播更新的参数


### vocab
vocab是模型的输入的字符的集合 也就是tokenizer.json里的词

### 反向传播
在CNN中 验证集比对的是预测结果是不是正确的

比如 这张图片是猫 而模型预测的是狗 那么模型损失函数会去根据此计算

而在RNN中 不可能去用验证集比对句子是否完全一样 这几乎是不可能的

所以在RNN中 验证集是去比对下一个字的概率分布
### 实现
```rust
struct Rnn{
	/// 隐藏状态权重矩阵
	w_xh: Tensor, // shape(in_dim,hidden_dim)
	/// 输入权重矩阵
	w_hh: Tensor, // shape(hidden_dim,hidden_dim)
	/// 隐藏状态偏置
	b_h: Tensor, // shape(hidden_dim)
	/// 全连接层权重矩阵
	w_hy: Tensor, // shape(hidden_dim,out_dim)
	/// 全连接层偏置
	b_y: Tensor, // shape(out_dim)
}
pub struct RnnConfig {
    /// 输入向量维度
    pub in_dim: usize,
    /// 隐藏状态维度(越大模型记忆越大但容易过拟合)
    pub hidden_dim: usize,
    /// 输出维度
    pub out_dim: usize,
    pub seq_len: usize,
}
```

```rust
impl Rnn{
	pub fn new(vb: &VarBuilder,imput_dim: usize,hidden_dim:usize,output_dim: usize) -> Result<Self>{
	let device = Device::Cpu;
	
	let w_xh = vb.get((config.in_dim, config.hidden_dim), "w_xh")?;
	let w_hh = vb.get((config.hidden_dim, config.hidden_dim), "w_hh")?;
	let b_h  = vb.get(config.hidden_dim, "b_h")?;
	let w_hy = vb.get((config.hidden_dim, config.out_dim), "w_hy")?;
	let b_y  = vb.get(config.out_dim, "b_y")?;
	Ok(Self{
	    w_xh,w_hh,b_h,w_hy,b_y
	})
	}
		
}
```
	


## LSTM
长短期记忆网络

![LSTM](../resource/lstm.png) 

lstm是RNN的一种变体与改进 解决了梯度爆炸的问题 以及RNN短期记忆有限的问题

lstm的核心设计是引入了`门控机制` 一共有三个门


### 门
- 输入门(i_t): 决定当前输入$x_t$多少信息写入cell状态$C_t$
- 遗忘门(f_t): 决定之前cell状态$C_{t-1}$多少保留
- 输出门(o_t): 决定最终隐藏状态$h_t$从cell状态中输出多少信息
- 候选状态($\tilde{C}_t$): 当前输入生成的候选cell状态

sigmoid函数的值域在(0,1) tanh的值域在(-1,1)

所以sigmoid函数可以控制信息流出的比例 tanh可控制信息的流出的方向


$$
i_t = sigmoid(W_ix x_t + W_ih h_{t-1} + b_i)
$$
$$
f_t = sigmoid(W_fx x_t + W_fh h_{t-1} + b_f)
$$

$$
o_t = sigmoid(W_ox x_t + W_oh h_{t-1} + b_o)
$$

$$
\tilde{C}_t = tanh(W_cx x_t + W_ch h_{t-1} + b_c)
$$

`注意 在实际实现中 w_ix w_fx w_ox w_cx都放在w_ih张量里 shape[4*hidden_dim,input_dim] w_hx等也同理在w_hh张量 偏置也是`

`而在合并起来后 其实就回到了RNN的公式 四个权重 四个偏置都合并`

### 记忆状态
本期记忆状态$C_t$由上期记忆状态$C_{t-1}$与遗忘门过滤后的结果哈达玛相乘 再加上本期新增的部分决定

$$
C_{t} = f(t) \circ C_{t-1} + i_t \circ \tilde{C}_t
$$

### 隐藏状态
隐藏状态=输出门与本期记忆状态的tanh结果哈达玛相乘

$$
h_t = o_t \circ tanh(C_t)
$$



## 注意力机制
Attention is All Your Need!

在早期的 RNN、LSTM 中，每个输入词对输出的影响是平均的。

但人类阅读时并不会平均看待所有词。 所以我们希望模型在处理某个词时， 能自动“聚焦”于输入中最相关的部分。 这就是注意力

假设有n个输入 注意力机制会使用 Q K V 来计算每个输入对其他n-1个输入的注意力分数 所以时间复杂度为 $O(n^2)$ 但是注意力机制的计算可以并行 所以实际几乎仍然比RNN快

注意力机制是强依赖embedding的正确性的 如果embedding是错误的 那么注意力分数会失效
### 缩放点积注意力
$$
Attention(Q,K,V) = softmax(\frac{Q K^T}{\sqrt(d_k)}) V
$$

![qkv](../resource/qkv.png)
在上面的公式中
- Q(shape[n,$d_k$])代表查询向量: 我要查找的信息
- K(shape[n,$d_k$]) V(shape[n,$d_k$])就是键值对的KV的意思
- $d_k$是键向量维度

假设输入为x(shape[1,m]) 则

Q(shape[1])

$$
x \cdot W_Q = Q

x \cdot W_K = K

x \cdot W_V = V
$$

$W_Q W_K W_V$是可训练的参数矩阵

Q和$K^T$点积 得到了相似度(点积反应相似度),相似度除以$\sqrt(d_k)$ 为了防止方差过大

上一步得到的结果与V点积 计算`加权求和`
#### 问题
- 无法捕捉多种关系 因为QKV的权重矩阵只有一组
- 表达能力有限
### 多头注意力机制
多头注意力机制是在这个过程的基础上 将原来的$W_Q W_K W_V$分给很多个注意力头 以让模型学习更多方面的信息 最后拼接(按列)起来

![multiattn](../resource/multiattn.png)

$$
MultiHead(Q,K,V) = Concat(head_1,head_2,..,head_h)W^O
$$

其中

$$
head_i = Attention(Q W^{Q}_i,KW^k_i,VW^V_i)
$$
### 多查询注意力机制
多头注意力机制的简化版

相当于多头注意力机制但是每个头的KV不是独立的 只有Q是独立的
### 掩码注意力机制
在训练时 模型如果看到后面的词 这样的话损失会直接接近0

所以需要对还没出现的词进行遮盖

将未出现的部分使用极小值进行遮盖 这就是掩码注意力机制

掩码是一个上或下三角矩阵

$$
\begin{bmatrix}
0 & -\infty & -\infty & -\infty \
0 & 0 & -\infty & -\infty \
0 & 0 & 0 & -\infty \
0 & 0 & 0 & 0
\end{bmatrix}
$$

在计算时 加上掩码

$$
Attention = \frac{Q K^T}{\sqrt{d_k}}  + Mask
$$
## 残差连接
当网络很深时 梯度在反向传播容易消失或爆炸

残差连接就是在网络层之间增加一个跳跃连接（skip connection），让网络学习残差而不是完整映射

假设我们希望学习

$$
y=H(x)
$$

如果学习$H(x)$很难 可改为学习残差$F(x) = H(x) -x$

残差也可以解决梯度消失的问题 假设在某一层的最优解是什么都不做 那么F(x) = 0 

导致梯度无法向下传播. 那么可以加入x 来避免这个问题
## 归一化
归一化就是把数据 调整到统一的尺度或范围，让不同特征或者数据之间更可比、更稳定。
- 消除量纲差异 降低数值差异对计算的影响

神经网络训练时，如果输入或者隐藏状态的数值范围差异太大，会出现几个问题: 梯度消失/爆炸 训练收敛慢 内部协变量偏移

归一化可以缓解这些问题，让网络训练更稳定、更快收敛。

### BatchNorm
对同一特征在一个batch内计算均值和标准差然后归一化
### LayerNorm
对单个样本的所有特征维度计算均值和标准差然后归一化
### InstanceNorm
对单个样本的每个通道进行归一化
### GroupNorm
把通道分成G组 每组内计算均值和方差然后归一化 是BatchNorm和InstanceNorm的折中方案
### RMSNorm
LayerNorm的变体 不同于 LayerNorm： RMSNorm 不减去均值（no centering），只做标准差/幅值归一化


## Transformers
这是由谷歌提出的框架 也是目前应用最广泛的框架

![transformers](../resource/transformers.png) 

编码器流程
```
输入 -> embedding -> 位置编码 -> [多头注意力机制 -> 残差+归一化 -> 前馈神经网络进行非线性变换(多层全连接层+非线性激活)] -> 多个[]循环 -> 输出
```

解码器流程

解码器接收两个输入 `编码器的输出` `之前已生成的序列`
```
                              之前的输出-----
                                           |
                                           |
编码器输出--->[掩码多头注意力层--->残差+归一化]-------->[多头注意力层---->残差+归一化---->前馈神经网络->残差+归一化]-> 多个[]循环 -> 全连接层-> 输出概率分布
```





### 位置编码
在Transofrmer中 是不依赖序列顺序的 所以需要使用位置编码

transformer采用sin-cos编码

$$
PE_(pos,2i) = sin(\frac{pos}{10000^{2i/d_model}})

PE_(pos,2i+1) = cos(\frac{pos}{10000^{2i/d_model}})
$$

其中:
- pos: token在序列的位置
- i: embedding的维度索引
- d_model: embedding的维度大小

意义: 不同位置的编码之间有平滑的相位差 模型可以通过线性组合推断相对位置
## kv_cache
在注意力模型推理的过程中 假设有n个输入 那么每生成一个token 需要重新计算前面所有的K V然后计算$Q K^T$ 这显然是浪费的

KV_Cache会保存前面每个token的KV以避免重复计算

```
step1: 计算 k0,v0 [k0][v0]
step2: 计算 k1,v1 [k0,k1][v0,v1]
..
```
## Todo
- BPE,Unigram
- kformer
## Mamba
2023年的新的序列模型 目前正在发展中 有望替代transformer 其中,提出者TriDao是Flash Attn算法的一作

在时间复杂度上 Mamba可缩减transformer的$O(n^2)$到O(n)

Mamba并不使用注意力机制 甚至不使用非线性层 而是转而使用工程学中的概念 SSM状态空间 而与传统SSM不同的是,Mamba的SSM状态方程的参数是*动态变化*的
![mamba](../resource/mamba.png)
### SSM
状态空间 这是一个来源于控制论的概念

`通过微分方程对动态系统的内部状态随时间演化进行建模，从而预测系统状态`

一个系统在任何时间的状态 都由`一定数量的系统变量所决定` 这些状态变量的每一个都应该`线性无关`

一个简单的例子: 牛顿力学下的汽车行驶

该系统的状态空间可用用两个状态变量来建模: 位置s与速度v.

因此 系统在任何时间t的状态都可以表示为一个二维向量(s,v) 因为只需要这两个量 你就可以预测它下一刻的位置

很多东西都可以拿来用状态空间建模: 华容道 甚至可以到整个世界

在理想数学意义下
```
如果能完整的知道状态空间的每个参数 并且拥有一个完美的状态转移方程 且算力无限 那么理论上可以计算整个未来和过去
```
#### 状态空间方程
离散的状态空间方程

$$
\begin{cases}
h_{t+1} = A h_t + B x_t \\
y_t = C h_t + D x_t
\end{cases}
$$

- $h_t$ 状态向量
- $x_t$ 输入向量
- $y_t$ 输出向量
- A 状态转移矩阵
- B 输入到状态的影响
- C 状态到输出的映射
- D 输入直接影响输出的部分

连续的状态空间方程

$$
\begin{cases}
\tilde{h}(t) = A h(t) + B x(t) \\
y(t) = C h(t) + D x(t)
\end{cases}
$$
#### 传统的SSM
在传统的SSM模型中 *A和B是不变的* 我们不难发现

$$
h_1 = B x_0 \\
h_2 = A h_1 + B x_1 = A (B x_0) + B x_1 \\ 
h_3 = A h_2 + B x_2 = A (A(B x_0) + B x_1) + B x_2= A^2 B x_0 + AB x_1 + B x_2 \\
... \\ 
h_n = \sum_{k=0}^{t-1} A^{t-1-k} B x_k 
$$

那么这就成为了`离散卷积`的行式 而离散卷积可使用`快速傅立叶变换`加速
#### Mamba的SSM
在mamba中 把序列建模任务看作一个状态空间

其中 每个时间都有一个隐状态$h_t$ 而输入的token $x_t$驱动更新

`Mamba让每个时间步的A B C依赖输入`

$$
\tilde{h}_{t} = A(h_t) h(t) + B(h_t) x(t) \\
y(t) = C(h_t) h(t)
$$

而且 Mamba中 A B C三个矩阵是`每个时间步不同`的 通过输入门控机制生成



所以Mamba是不能使用卷积展开的 也不能使用快速傅立叶变换加速 但是Mamba提出了一个高效的计算方法


#### 并行扫描
虽然不能利用卷积的性质和快速傅立叶变换 但是Mamba使用了一个新的方法: 并行扫描

我们知道 h的公式为

$$
h_t = A_t h_{t-1} + B_{t} x_{t-1}
$$

在正常情况下 这个递推是*顺序的* 每步都依赖于前一步的h

我们来写出几个时间步的h

$$
h_0 = 0 \\
h_1 = B_1 x_1 \\ 
h_2 = A_2 (B_1 x_1) + B_2 x_2 = A_2 B_1 x_1 + B_2 x_2 \\ 
h_3 = A_3 A_2 B_1 x_1 + A_3 B_2 x_2 + B_3 x_3 
$$

则有

$$
h_t = \sum_{k=1}^{t} (\prod_{j=k+1}^{t} A_j)B_k x_k
$$
### 使用
```
pip install mamba-ssm
```

```python
import torch
from mamba_ssm import Mamba

batch, length, dim = 2, 64, 16
x = torch.randn(batch, length, dim).to("cuda")
model = Mamba(
    # This module uses roughly 3 * expand * d_model^2 parameters
    d_model=dim, # Model dimension d_model
    d_state=16,  # SSM state expansion factor
    d_conv=4,    # Local convolution width
    expand=2,    # Block expansion factor
).to("cuda")
y = model(x)
assert y.shape == x.shape
```
## Unet
U-Net 是 1995 年提出的医学图像分割经典网络 是`图像分割`领域的标准架构

U-Net 是一种CNN 专门为 `像素级预测任务` 设计

U-Net的核心创新点在于引入了跳跃连接

![U-Net](../resource/unet.png)

U-Net的结构图如同一个U 故受之以U

而U的左边是编码器 也叫收缩路径

U的右边是解码器 也叫扩张路径


### 编码器
编码器的作用是提取图像的语义特征

- 操作: 使用重复的卷积 ReLU激活 最大池化

- 每下采样一次 空间分辨率减半 通道数加倍

在编码器的过程中 语义理解逐渐增强 但是空间定位信息变弱
### 解码器
恢复空间分辨率 同时利用语义特征进行定位

- 操作: 上采样 跳跃连接拼接  卷积

#### 跳跃连接
对应结构图中灰色的直线 把编码器对应层的特征图拼接到一起

在解码阶段 跳跃连接把编码器中相同分辨率的特征图拼接回来 补回空间细节

那么 既然跳跃连接只是把空间信息矩阵和语义信息矩阵拼接在一起，那为什么输出就能还原出图像?

我们知道

$$
F = Concat(F_{up},F_{skip})
$$

即左边是解码器的上采样 右边是编码器的提取的特征 为什么可以合并成图?

这个在模型的训练中 卷积核会去学习如何融合它们俩 所以最后会融合起来
## 贝叶斯优化
贝叶斯优化是一种在黑盒函数(几乎没有这个函数任何信息)中找到全局最优值的方法

作用的函数的特点:

- 没有解析式 没有导数信息 不知道是否连续... 几乎只知道输入对应的输出

我们需要的效果:
- 仅考虑最大(小)值 
- 尽可能少的次数

贝叶斯优化很适合这种任务

贝叶斯优化在一个迭代循环中运行 每一步都围绕着平衡两个目标: **开发** 和 **探索**

### 核心组件
贝叶斯优化的两个核心组件: 代理模型 和 采集函数

#### 代理模型
代理模型是 使用历史的观测数据来拟合f(x)的曲线的模型
 
通常使用高斯过程GP
	
##### 高斯过程
GP是一种强大的 非参数化的回归方法.

GP会假设f(x)服从多维高斯分布

$$
f(x_1),f(x_2),...,f(x_n) \sim N(\mu,K)
$$

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import Matern, ConstantKernel as C

# 训练点 在贝叶斯优化中由采集函数传给GPR
X_train = np.array([[1], [3], [5], [6], [7.5]])
y_train = np.sin(X_train).ravel()

# 核函数 在贝叶斯优化中 我们经常使用Matern
kernel = Matern()

# 使用GPR高斯过程回归
gp = GaussianProcessRegressor(kernel=kernel, n_restarts_optimizer=10, alpha=1e-6, normalize_y=True)

# 拟合训练数据
gp.fit(X_train, y_train)

# 生成预测点
X_test = np.linspace(0, 10, 200).reshape(-1, 1)
y_pred, sigma = gp.predict(X_test, return_std=True)  # 返回均值和标准差


plt.figure(figsize=(10,5))

plt.plot(X_test, y_pred, 'b-', label='GP Mean')

plt.plot(X_test, np.sin(x_test), label='sinx')
# 不确定性带（±1 std）
plt.fill_between(X_test.ravel(),
                 y_pred - sigma,
                 y_pred + sigma,
                 alpha=0.2, color='blue', label='GP ±1 std')
# 训练点
plt.scatter(X_train, y_train, c='r', marker='o', s=50, label='Training Data')
plt.title("Gaussian Process Regression")
plt.xlabel("x")
plt.ylabel("y")
plt.legend()
plt.grid(True)
plt.show()
```
###### 核函数
核函数是高斯过程**最重要**的组件 它决定了对目标函数形状的**先验假设**

在实际运用中 核函数的参数是训练调优的 通过LML最大化边界似然来完成

常用的核函数

- RBF: 高斯核 也叫平方指数核

假设目标函数无限平滑 无限可微 确信你的目标函数**非常光滑** 没有高频噪声或剧烈突变

$$
k(x_i,x_j) = exp(-\frac{d(x_i,x_j)^2}{2l^2})
$$
- Matern: **最常用**的 RBF的泛化形式 通过`nu`参数控制平滑度

$$
k(x_i,x_j) = \frac{1}{\Gamma(v)2^(v-1)} (\frac{\sqrt{2 nu}}{l} d(x_i,x_j))^(nu) K_v (\frac{\sqrt{2 nu}}{l} d(x_i,x_j))
$$
其中
  - d为欧几里得距离
  - $K_v$是修正的贝塞尔函数
  - $\Gamma$是欧拉的那个积分
  - nu = 0.5 非常粗糙
  - nu = 1.5 一次可导
  - nu = 2.5 二次可导 是BO的默认首选
  - nu = $\infty$ 收敛于RBF
- RationalQuadratic: 有理二次核 多个不同length_scale的RBF核的无穷和

允许函数在不同的尺度上发生变化 比 RBF 更灵活 能够同时容纳大尺度的波动和小尺度的细节

当你不确定函数的波动频率是否一致时 可以使用
- ExpSineSquard: 周期核

为周期性规律设计的 适用于时间序列数据 季节性数据 或者类似正弦波的物理现象


通常加在其他核上
#### 采集函数
采集函数接收代理模型提供的**预测均值**和**预测方差** 去计算在整个搜索空间中 哪个点的潜在价值最高 同时要平衡**开发**与**探索**的权重

常用的采集函数:

- EI: 期望提升

计算通过在x处采样 能够比当前已知的最佳值提升的期望量

$$
EI(x) = \begin{cases}
(\mu(x) - \mu_(best) - \xi)\Phi(Z) + \sigma(x)\phi(Z), \sigma(x) > 0 \\
0, \sigma(x) = 0
\end{cases}
$$

其中

$$
Z = \frac{\mu(x) - \mu_{best} - \xi}{\sigma(x)}
$$

Z反应了获得改进的概率

$\mu(x)$: 高斯过程模型在x的预测值

$\sigma(x)$: 高斯过程在x的不确定性

$\mu_{best}$: 当前最优值

$\xi$: 平衡系数 平衡探索与开发 $\xi$ 越大 越倾向于探索

$\Phi(Z)$: f(x)能超过当前最优值的概率 若Z很大 则$\Phi(Z)$ 接近1

$\phi(Z)$: f(x)超过当前最优值提升的幅度

- UCB: 上置信界

简单的将预测均值$\mu$ 加上不确定性$\sigma$的缩放版本 

$$
UCB(x) = \mu(x) + \beta \cdot \sigma(x)
$$

其中

$\mu(x)$ 是高斯过程得出的预测均值

$\sigma(x)$ 是高斯过程得出的不确定性

$\beta$ 是权重 平衡开发与探索

乐观主义的策略: 我们永远选择最乐观的点去采样

$\mu$告诉我们函数值可能的值 而$\beta \cdot \sigma(x)$告诉我们若运气好 函数能到的边界

##### LML
优化高斯过程核的参数的过程其实和反向传播是类似的 计算LML的梯度然后优化器更新

边际似然 在高斯过程中 我们假设观测到的数据y服从一个多维高斯分布 LML 就是这个多维高斯分布的概率密度函数的对数

LML的公式可以分解为三个部分
$$
\log p(\mathbf{y} \mid X, \theta) = \underbrace{-\frac{1}{2} \mathbf{y}^T (\mathbf{K} + \sigma_n^2 \mathbf{I})^{-1} \mathbf{y}}_{\text{I. 数据拟合优度 (Data Fit)}} \underbrace{- \frac{1}{2} \log |\mathbf{K} + \sigma_n^2 \mathbf{I}|}_{\text{II. 模型复杂度惩罚 (Complexity Penalty)}} \underbrace{- \frac{N}{2} \log(2\pi)}_{\text{III. 常数项}}
$$

- 数据拟合优度: 衡量模型预测值与实际观测值的匹配程度
- 模型复杂度: 防止过拟合
- 常数项: 标准化用 不影响优化过程

LML的优化过程就是使用优化器来找到一组$\theta$ 使上述LML的值最大 

这是通过在每次的高斯过程的循环中更新的


### 示例
这里的黑盒函数是

$$
f(x) = sin(5x) \cdot (1 - tanh(x^2))
$$

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import Matern
from scipy.stats import norm

def target_function(x):
    return np.sin(5 * x) * (1 - np.tanh(x ** 2))

def expected_improvement(X, X_sample, Y_sample, gpr, xi=0.01):
	# 由高斯过程回归得到预测均值和预测标准差
    mu, sigma = gpr.predict(X, return_std=True)
    mu = mu.ravel()
    sigma = sigma.ravel()
    
    mu_sample = gpr.predict(X_sample)
    mu_sample_opt = np.max(mu_sample)

    with np.errstate(divide='warn'):
        imp = mu - mu_sample_opt - xi
        Z = imp / sigma
        ei = imp * norm.cdf(Z) + sigma * norm.pdf(Z)
        ei[sigma == 0.0] = 0.0
    return ei


# 搜索空间
X_bound = np.linspace(0, 2, 200).reshape(-1, 1)
y_true = target_function(X_bound)

# 初始观测点
X_train = np.array([[0.1], [0.5]])
y_train = target_function(X_train)

# 定义内核和模型
kernel = Matern()
gpr = GaussianProcessRegressor(kernel=kernel, alpha=1e-6, n_restarts_optimizer=10)

# 设置迭代次数
n_iterations = 3


fig, axes = plt.subplots(n_iterations, 2, figsize=(12, 4 * n_iterations), sharex=True)
plt.subplots_adjust(hspace=0.3)


for i in range(n_iterations):
    
    # GPR拟合
    gpr.fit(X_train, y_train)
    
    # 由GPR得到均值核方差
    mu, std = gpr.predict(X_bound, return_std=True)
    mu = mu.ravel()
    std = std.ravel()
    
    # 计算采集函数EI的值
    ei = expected_improvement(X_bound, X_train, y_train, gpr)
    
    # 把EI给的下一个点加入到GPR的探测点中
    next_x_idx = np.argmax(ei)
    next_x = X_bound[next_x_idx]
    next_y_val = target_function(next_x) 
    
    
    ax_model = axes[i, 0] 
    ax_acq = axes[i, 1]      
    ax_model.plot(X_bound, y_true, 'k--', alpha=0.5, label='Ground Truth')
    ax_model.plot(X_bound, mu, 'b-', label='GP Mean')
    ax_model.fill_between(X_bound.ravel(), mu - 1.96 * std, mu + 1.96 * std, 
                          alpha=0.2, color='blue', label='95% Confidence')
    
    ax_model.scatter(X_train, y_train, c='black', s=40, zorder=10, label='Existing Data')
    
    ax_model.axvline(x=next_x, color='red', linestyle='--', alpha=0.6)
    ax_model.scatter(next_x, mu[next_x_idx], c='red', s=100, marker='*', zorder=15, label='Next Candidate')
    
    ax_model.set_title(f"Iteration {i+1}: Surrogate Model", fontsize=12, fontweight='bold')
    ax_model.set_ylabel("Output $f(x)$")
    if i == 0: ax_model.legend(loc='upper left', fontsize=8)

    
    ax_acq.plot(X_bound, ei, 'g-', label='Expected Improvement')
    ax_acq.fill_between(X_bound.ravel(), 0, ei, color='green', alpha=0.3)
    
    ax_acq.axvline(x=next_x, color='red', linestyle='--', alpha=0.6)
    
    ax_acq.set_title(f"Iteration {i+1}: Acquisition Function (EI)", fontsize=12)
    ax_acq.set_ylabel("Utility")
    
    
    X_train = np.vstack((X_train, next_x))
    y_train = np.vstack((y_train, next_y_val))


axes[-1, 0].set_xlabel("Input $x$")
axes[-1, 1].set_xlabel("Input $x$")

plt.tight_layout()
plt.show()

```
## vit
Vision Transformer

在图像任务上使用Transformer模型

把图像切成 patch，当成 token 输入 Transformer，完全抛弃了 CNN 卷积结构，最终在大规模数据上超过传统 CNN（如 ResNet）。

![VIT](../resource/vit.gif)

### 架构
```
输入分割 ->线性投影-> 位置编码-> 训练->分类/分割
```

- 输入分割: 一般裁剪为16*16 这是有实验作为支撑的经验数据
- 线性投影: 补丁转化为向量 将每个patch的张量展平为shape(1,n)的向量

会有一个`可学习`的线性投影层(全连接层) 将这个向量映射到固定的维度D上 这个D就是transformer的hidden_size 它被称为`patch_embedding`

然后会在`patch_embedding`后的向量的前缀加一个`可学习`的CLS token

cls token的作用是`分类标记` 作为全局表示符号 收集整个图像的信息

所有的输入 token（在 ViT 中即每个 patch）会经过一系列的自注意力层（Self-Attention），而 [CLS] token 通过这个过程积累了所有 patch 信息的“摘要”或“总结”。

*为什么它有全局信息?*

在 transformer模型中 一个token会对一个batch_size所有的token计算注意力分数 所以cls token有对其他token的注意力分数

- 位置编码: 告诉模型 每个补丁的原始空间位置. 

我们来回顾一下 很多机器学习架构都需要对图形的空间信息做特殊处理

比如在U-Net中 会把保存有空间信息的下采样的张量通过跳跃连接拼接到上采样的张量

那么在VIT中:
1. 创建`可学习`的位置编码矩阵 `shape(D,n+1)` +1是cls token
2. 将这个矩阵加到patch_embedding的矩阵上
- 送入transformer
- 根据任务决定输出
1. 图像分类任务: 将cls token的输出连接一个全连接层然后和CNN一样得到概率分布
2. 图像分割任务: 上采样 然后通过像素级分级

### 使用
```
pip install vit-pytorch
```

```python
import torch
from vit_pytorch import ViT

v = ViT(
    image_size = 256,
    patch_size = 32,
    num_classes = 1000,
    dim = 1024,
    depth = 6,
    heads = 16,
    mlp_dim = 2048,
    dropout = 0.1,
    emb_dropout = 0.1
)

img = torch.randn(1, 3, 256, 256)

preds = v(img) # (1, 1000)
```

其中
- image_size: 图像尺寸
- patch_size: 补丁大小(必须能被image_size)整除
- num_classes: 分类数量
- dim: 隐藏层维度
- depth: transformer的数量
- heads: 多头注意力的头数
- mlp_dim: 前馈层的维度
- channels: 和cnn一样
- dropout: [0,1]


## GNN
图神经网络

这里的图就是传统算法结构中的图 故不多讲述

我们知道: 在欧式空间中 以往的神经网络可以很好的训练. 但是在面对非欧空间时 就不太行了 所以我们使用GNN

那么我们如何解决 让图抽象为可以训练的结构

GNN的核心就是 图矩阵(邻接矩阵)的表示 和 层与层的消息传递

### GNN处理的任务
- 节点分类: 给定节点 预测类型
- 链路预测: 预测两个节点是否有连接
- 社区检测: 确定具有紧密连接关系的节点
- 网络相似度: 衡量两个网络或子网络之间的相似性

### GCN
图卷积神经网络


#### 使用
```python
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.datasets import Planetoid
from torch_geometric.nn import GCNConv

class GCN(nn.Module):
    def __init__(self, in_channels, hidden_channels, out_channels):
        super().__init__()
        self.conv1 = GCNConv(in_channels, hidden_channels)
        self.conv2 = GCNConv(hidden_channels, out_channels)

    def forward(self, x, edge_index):
        x = self.conv1(x, edge_index)
        x = F.relu(x)
        x = F.dropout(x, training=self.training)
        x = self.conv2(x, edge_index)
        return x
```
## PCGrad
投影解决梯度冲突

在实际情况中 经常遇到两个任务的梯度方向冲突(内积<0) 则我们需要将一个梯度在另一个梯度的正交子空间投影


## k-近邻
## 决策树
## 支持向量机

## TPE
基于树结构的贝叶斯优化
## 域
域代表数据的分布和特征空间
## 迁移学习
迁移学习是把一个**已有模型**的知识迁移到新任务上

利用源域的知识提升目标域的性能

在我们正常的机器学习中 训练数据与测试数据应该满足 **训练数据和测试数据满足同一分布**

而在现实的应用中 源域和目标域的分布可能会有差异 而迁移学习就是允许模型在不同分布的情况下 **进行有效的知识迁移**

### 域
通常指数据的**特征空间**及其**概率分布**的特定上下文或环境 它包含了数据所处的具体背景和场景

#### 特征空间
用于表示数据特征的高维空间

在NLP中 就是embedding后的词向量的空间

#### 概率分布
随机变量取值可能性的函数或公式

如果源域和目标域下的分布不同 那么会导致模型在目标域下的表现不佳


### 领域自适应
领域自适应是迁移学习的代表方法 利用信息丰富的源域样本提升目标模型的性能

源任务和目标**任务一样** 但是源域和目标域的**数据分布不一样** 并且源域有**大量**的标记好的样本 目标域则没有（或者只有**非常少的**）有标记的样本的迁移学习方法

**源域和目标域往往属于同一类任务，但是分布不同**

#### 特征自适应
样本自适应是直接在**样本层面** 调整 使源域样本**更像**目标域

在传统的学习中 我们的目的是通过优化器来最小化平均损失

即找到一个$\theta$使得

$$
min \frac{1}{n}\sum_{i=1}^{n}L(x_i,y_i,\theta)
$$

而在特征自适应中 我们需要通过一个新的映射$\Phi$ 使得源域和目标域在特征空间的分布**对齐**

所以我们不仅学习模型参数$\theta$ 也学习这个映射$\Phi$

即

$$
min\frac{1}{n}\sum_{i=1}^{n}L(\Phi(x_i),y_i,\theta)
$$

##### MMD
Maximum Mean Discrepancy 最大均值差异

在再生希尔伯特空间(RKHS)中计算两个分布的均值差距

###### 希尔伯特空间
首先我们介绍希尔伯特空间

希尔伯特空间是一个**向量空间** 它具有以下特征

- 是一个向量空间: 向量可以相加 可以数乘
- 拥有内积: $\langle f,g \rangle$
- 完备

在希尔伯特空间中 距离定义为:

$$
d(x,y) = \|x - y \|
$$

其中范数由内积诱导: 

$$
\|x\| = \sqrt{\langle x,x \rangle}
$$

则距离为

$$
d(x,y) = \sqrt{\langle x-y,x-y \rangle}
$$

- 在欧几里得空间中

内积就是点积

所以

$$
\langle x,y \rangle = \sum_{i} x_i y_i
$$

则

$$
d(x,y) = \sqrt{\sum_i (x_i - y_i)^2}
$$

- 在函数空间中

内积定义为积分

$$
\langle f,g \rangle = \int f(t) g(t) dt
$$

所以

$$
d(f,g) = \| f - g \| = \sqrt{\int |f(t) - g(t) |^2 }
$$
###### 再生希尔伯特空间RKHS
在传统的希尔伯特空间中 积分对单个点是不敏感的

$$
\| f - g\|^2 = \int |f(x) - g(x)|^2 dx
$$

假设有函数f(x) 和函数g(x)

g(x)和f(x)几乎一模一样 而在x=0上 g(x) 远大于 f(x)

但是在积分看来 它们的距离是0 因为单点的面积是0(勒贝格测度) **所以表示不出距离**

所以我们引入再生希尔伯特空间

在传统的函数希尔伯特空间中 点求值f(x)是**不稳定**的. 再生性保证了在RKHS中 f(x)是**连续且稳定**的泛函

而RKHS还带来了另一个好处,再生性:

**对于再生希尔伯特空间中的任何函数f(x) 以及任意点x ,f(x) 等于f向量与 K(\cdot,x)向量的内积**

$$
f(x) = \langle f,K(\cdot,x) \rangle
$$

再生性赋予了再生希尔伯特空间一个独特的能力: 在这个空间里 你可以通过纯粹的几何操作**内积**来读取函数在特定点上的值

**也就是说 我们并不需要直接计算f(x) 可以通过计算核函数和f来直接得到f(x)**
##### CORAL
Correlation Alignment 相关性对齐

对齐源域和目标域特征的**二阶统计量**
##### DANN
Doamin-Adversarial Neural  Networks 基于对抗学习的方法
#### 实例自适应
实例自适应不是对样本**更改分布** 或者**对齐** 而是对样本进行**加权**

对源域中有用的样本权重大 对目标域没有帮助的样本低权重甚至忽略


$$
min\frac{1}{n}\sum_{i=1}^{n}w_i L(x_i,y_i,\theta)
$$
