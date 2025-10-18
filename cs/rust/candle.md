# Candle
Huggingface研发的Rust的LLM框架

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
优化器


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

```
use candle_core::{Tensor,Device::Cpu};
use candle_nn::{Linear,Module};

let w = Tensor::new([[1f32,2.], [3.,4.],[5.,6.]], &Cpu)?;
let layer = Linear::new(w,None);
let xs = Tensor::new(&[[10f32,100.]],&Cpu)?;
let ys = layer.forward(&xs)?;
```

### loss
损失函数
