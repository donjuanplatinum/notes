# Candle
Huggingface研发的Rust的LLM框架

## candle-core
保存了张量的类型和基本操作
### Tensor
张量

方法:
#### 形状改变
- `flatten_all(&self) -> Result<Tensor>`: 将整个张量展平为一维
```rust
[[0,1],[2,3],[4,5]] -> [0,1,2,3,4,5]
(3,2) -> (6)
```
- `flatten_from<D: Dim>(&self,start_dim:D) -> Result<Tensor>`: 从start_dim维度开始展平到最后一个维度 [start_dim,last_dim]
```rust
// CNN全连接层的输入
let tensor = Tensor::new(&[[[0f32,1.], [2.,3.]], [[4.,5.], [6.,7.]], [[8.,9.], [10.,11.]]], &Device::Cpu)?; //shape(3,2,2)
let tensor = tensor.flatten_from(1)?; // to shape(3,4)
```
- `flatten_to<D: Dim>(&self,end_dim: D) -> Result<Tensor>`: 从0维度展平到end_dim维度 [0,end_dim]
- `flatten<D1:Dim,D2: Dim>(&self,start_dim: D1,end_dim:D2)-> Result<Tensor>`: 从start_dim展平到end_dim [start_dim,end_dim]
- `reshape<S: ShapeWithOneHole>(&self, s: S) -> Result<Tensor>`: 按照s元组指定的形状将张量变形 ()表示自动推断
``` rust
let c = a.reshape((2, (), 1))?;
assert_eq!(c.shape().dims(), &[2, 3, 1]);
```
#### 运算
- `max_pool2d<T: ToUsize2>(&self,sz: T)-> Result<Self>`: 将4维的张量`shape(batch_size,channels,high,weigth)`最大池化 池化核的尺寸为`sz` 默认没有填充 步长默认为sz
- `cmp<T: TensorOrScalar>(&self,rhs: T,op:CmpOp) -> Result<Self`: 对两个张量逐元素比较 比较函数为op 返回结果张量
- `mean<D: Dims>(&self,mean_dims: D)-> Result<Self>`: 对mean_dims维度求均值
- `var<D: Dims>(&self,dim: D)-> Result<Self>`: 对dim求方差
- `t(&self) -> Result<Self>`: 转置
#### 初始化
- `randn<S: Into<Shape>,T: FloatDType>(mean: T,std:T,s: S,device: &Device) -> Result<Self>`: 按照指定的形状s 均值mean 标准差std创建张量

#### 信息接口
- `dim<D: Dim>(&self,dim:D)-> Result<usize>`: 返回指定维度的大小
- `shape(&self) -> &Shape`: 返回张量形状
#### 取出子张量
- `narrow<D: Dim>(&self,dim:D,start:usize,len:usize) -> Result<Self>`: 从原始张量中取出(不复制 高性能)一部分子张量 沿维度dim 从索引start开始 提取长度为len的子张量
#### 查询
- `argmax<D: Dim>(&self, dim: D) -> Result<Self>`: 沿着D维度返回最大值
- `argmin<D: Dim>(&self, dim: D) -> Result<Self>`: 沿着D维度返回最大值

#### 多张量拼接
- `stack<A: AsRef<Tensor>, D: Dim>(args: &[A], dim: D) -> Result<Self>`: 把一组形状相同的张量沿着一个维度拼接 
- `chunk<D: Dim>(&self,chunks:usize,dim: D)-> Result<Vec<Self>>`: 把张量沿着dim维度切分成chunks个 但可能小于chunks个
t1 = [[1,2],[3,4]];

t2 = [[5,6],[7,8]];

t3 = [[9,10],[11,12]];

他们的形状为[2,2]

则按照0维拼起来为[3,2,2]
```rust
let y = Tensor::stack(&[t1,t2,t3],0)?;
```

结果为
```
y.shape = [3,2,2];
y = [[[1,2],[3,4]],
	[[5,6],[7,8]],
	[[9,10],[11,12]],
]
```

### shape
#### D
维度
```rust
pub enum D {
    Minus1,
    Minus2,
    Minus(usize),
}
```

其中: 
- Minus1: 最后一维
- Minus2: 倒数第二维
- Minus(usize): 第usize维
## candle-nn
candle的神经网络

### var_map
VarMap是保存命名变量的存储库。
#### VarMap
VarMap保存了模型的参数.

VarMap结构体可以以 safetensors 格式序列化。

存储所有参数张量（Tensor），按名称索引，例如 "conv1.weight"、"fc2.bias"

方法:
- `new`: 初始化
- `all_vars(&self) -> Vec<Var>`: 检索当前Map中所有变量
- `save<P: AsRef<Path>>(&Self,path:P)-> Result<()>`: 以safetensors格式保存
- `load<P: AsRef<Path>>(&mut self,path:P)-> Result<()>`: 以Safetensors文件加载一些值 并修改现有变量 当前不在映射中的变量的值不会被保留。
- `set_one<K: AsRef<str>, V: AsRef<Tensor>>(&mut self,name: K,value: V) -> Result<()>`: 设置变量的值
- `set<I: Iterator<Item = (K,V)>,K: AsRef<str>,V: AsRef<Tensor>>(&mut self,iter: I)-> Result<()`: 设置一些变量
### var_builder
VarBuilder用于从模型中检索变量
#### VarBuilder
VarBuilder 是个工厂对象，用来帮你创建网络层的参数。

它不会自己保存参数，而是向 VarMap 注册参数。

方法:
- `from...`: 从对应的类型创建varbuilder
- `zeros`: 初始化VarBuilder为任何张量为0
- `get<S: Into<Shape>>(&self,s:S,name: &str)-> Result<Tensor>`: 检索当前路径上与给定名称关联的张量
- `push_prefix<S: ToString>(&self,s: S)`: 生成一个新的VarBuilder 在原始参数路径前加入s. 类似cd
### activation
激活函数
### conv
卷积层
#### conv2d
构建Conv2d类型的构建函数
``` rust
pub fn conv2d(
	in_channels: usize,
	out_cahnnels: usize,
	kernel_size: usize,
	cfg: Conv2dConfig,
	vb: VarBuilder<'_>,
) -> Result<Conv2d>
```

- in_channels: 输入特征图的通道 灰度图是1 RGB是3
- out_channels: 卷积层输出特征图的数量(卷积核数量) 典型的如32 64 128
- kernel_size: 卷积核尺寸
- config: 卷积层的配置Conv2dConfig
- vb: VarBuilder

#### Conv2dConfig
Conv2d层的配置
``` rust
pub struct Conv2dConfig {
    pub padding: usize,
    pub stride: usize,
    pub dilation: usize,
    pub groups: usize,
    pub cudnn_fwd_algo: Option<CudnnFwdAlgo>,
}
```
- padding: 填充 在输入数据边界填充的像素数
- stride: 卷积核滑动步长
- dilation: 空洞卷积(膨胀卷积)的间距
- groups: 分组卷积控制输入输出通道分组
- cudnn_fwd_algo: 指定cuDNN的前向算法

default trait:
```
impl Default for Conv2dConfig {
    fn default() -> Self {
        Self {
            padding: 0,
            stride: 1,
            dilation: 1,
            groups: 1,
            cudnn_fwd_algo: None,
        }
    }
}
```
#### Conv2d
卷积层类型
``` rust
#[derive(Clone, Debug)]
pub struct Conv2d {
    weight: Tensor,
    bias: Option<Tensor>,
    config: Conv2dConfig,
}
```

方法:
- `new(weight: Tensor,bias: Option<Tensor>,config: Conv2dConfig)-> Self`: 构建函数
- `forward(&self,x: &Tensor)-> Result<Tensor>`: 经过这一层
### optim
优化器 用于计算梯度并更新模型参数
#### AdamW
adamW优化器
##### new_lr
AdamW构建器
```rust
new_lr(vars: Vec<Var>,
learning_rate: f64) -> Result<Self>
```

其中：
- vars: 在训练过程中更新的模型参数
- learning: 学习率

##### backward_step
反向传播并更新参数
```rust
backward_step(&mut self, loss:
&Tensor) -> Result<()>
```
### linear
#### linear
构建全连接层
```rust
pub fn linear(
    in_dim: usize,
    out_dim: usize,
    vb: VarBuilder<'_>,
) -> Result<Linear>
```

- in_dim: 输入维度(向量的维度)
- out_dim: 输出维度
- vb: VarBuilder
#### Linear
全连接层 对输入数据应用线性变换

```rust
use candle_core::{Tensor,Device::Cpu};
use candle_nn::{Linear,Module};

let w = Tensor::new([[1f32,2.], [3.,4.],[5.,6.]], &Cpu)?;
let layer = Linear::new(w,None);
let xs = Tensor::new(&[[10f32,100.]],&Cpu)?;
let ys = layer.forward(&xs)?;
```

### loss
损失函数
#### nll
负对数似然损失
```rust
nll(inp: &Tensor, target: &Tensor) -> Result<Tensor>
```

其中:
- inp是预测的结果
- target是真实的标签的张量
#### cross_entropy
交叉熵损失
```rust
cross_entropy(inp: &Tensor, target: &Tensor) -> Result<Tensor>
```
- inp是预测的结果
- target是真实的标签的张量

### ops
张量操作
#### log_softmax
对输入张量的维度生成对数概率
```rust
log_softmax<D: Dim>(xs: &Tensor, d: D) -> Result<Tensor>
```

其中:
- d: 作用的维度 一般是最后一个维度D::Minus1


例如对全连接层的输出转换为概率
```rust
let output = linear.forward(&tensor)?;
let result = log_softmax(&output,candle_core::D::Minus1)?;
```
#### softmax
对输入张量的维度生成概率
```rust
softmax<D: Dim>(xs: &Tensor, dim: D) -> Result<Tensor>
```

其中:
- d: 作用的维度 一般是最后一个维度D::Minus1
### rnn
循环神经网络
#### LSTM
长短期记忆模型
```rust
pub struct LSTM {
	// 应用于输入的四个偏重 w_ix w_fx w_cx w_ox
    w_ih: Tensor, 
	// 应用于隐藏状态的四个偏重 w_ih w_fh w_ch w_oh
    w_hh: Tensor,
	// 应用于输入的四个偏置
    b_ih: Option<Tensor>,
	// 应用于隐藏状态的四个偏置
    b_hh: Option<Tensor>,
	// 隐藏层维度 是超参数
    hidden_dim: usize,
    config: LSTMConfig,
    device: Device,
    dtype: DType,
}
```

#### LSTMConfig
lstm的配置
```rust
pub struct LSTMConfig {
	/// 各种偏重 偏置的初始化方式
    pub w_ih_init: Init,
    pub w_hh_init: Init,
    pub b_ih_init: Option<Init>,
    pub b_hh_init: Option<Init>,
	
	/// 当前lstm层索引层号(多层lstm用)
    pub layer_idx: usize,
	/// lstm方向 前或后 用于双向lstm
    pub direction: Direction,
}
```
#### lstm
LSTM构建函数
```rust
pub fn lstm(
    in_dim: usize, 
    hidden_dim: usize,
    config: LSTMConfig,
    vb: VarBuilder<'_>,
) -> Result<LSTM>
```
其中:
- in_dim: 输入维度
- hidden_dim: 隐藏状态维度
### init
初始化方法
#### Init
初始化方法的enum 用于初始化一开始的偏重 偏置
```rust
pub enum Init {
	/// 常量
    Const(f64),
	/// 正态分布
    Randn {
        mean: f64,
        stdev: f64,
    },
	/// 均匀分布
    Uniform {
        lo: f64,
        up: f64,
    },
	/// kaiming初始化
    Kaiming {
        dist: NormalOrUniform,
        fan: FanInOut,
        non_linearity: NonLinearity,
    },
}
```
