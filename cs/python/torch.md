# Torch
python的深度学习框架

子模块
- torch: 类似candle-core 基础的Tensor类型
- torch.autograd: 自动求导系统
- torch.nn: 神经网络
- torch.optim: 优化器
- torch.utils: 工具
- torch.cuda: GPU支持
- torch.linalg: 线性代数
- torch.fft: 快速傅立叶变换
- torch.special: 数学函数
- torch.random: 随机数
- torch.distributions: 概率分布
- torch.fx: 动态计算图抽象
- torch.onnx: ONNX格式模型
- torch.profiler: 性能分析
- torchvision: 图像处理

## Hook
Pytorch中的Hook触发对象为`Tensor`或者`nn.Module` 在对象的**前向传播**或者**反向传播**中触发

### module_hook
作用于模块的钩子

注册函数:

- 前向传播

```
torch.nn.modules.module.register_forward_hook(hook_fn)
```

- 反向传播

```
torch.nn.modules.module.register_full_backward_hook(hook_fn)
```

模块hook函数接收三个参数

```python
hook_fn(module,input,output)
```

其中
- module: 被hook的layer
- input: layer的输入元组
- output: layer的输出元组

#### 例子
##### 在CNN查看反向传播的梯度
```python
class CNN(nn.Module):
    def __init__(self,num_class,channels,high,weight):
        super().__init__()
        h = high // 4
        w = weight // 4
        linear_1 = int(128 * h * w)
        self.features = nn.Sequential(
            nn.Conv2d(channels,32,kernel_size=3,stride=1,padding=1),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2,stride=2),
            nn.Conv2d(32,128,kernel_size=3,stride=1,padding=1),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2,stride=2)
        )
        self.classifier = nn.Sequential(
            nn.Linear(linear_1,64),
            nn.ReLU(),
            nn.Linear(64,num_class)
        )
    def forward(self, x):
        x = self.features[0](x)
		# 给第一个卷积层加hook
        x.register_hook(lambda g: print("Conv1 grad mean =", g.mean().item()))
        x = self.features[1](x)
        x = self.features[2](x)
        x = self.features[3](x)
        x = self.features[4](x)
        x = self.features[5](x)

        x = x.view(x.size(0), -1)
        x = self.classifier(x)
        return x
```




##### 梯度消失和梯度爆炸报警器
这是检查函数
```python
def check_grad(name, grad, explode_th=1e3, vanish_th=1e-7):
    maxv = grad.abs().max().item()
    meanv = grad.abs().mean().item()

    if maxv > explode_th:
        print(f"[Expoding Gradient] {name}: max={maxv:.4e}")

    if maxv < vanish_th:
        print(f"[Vanishing Gradient] {name}: max={maxv:.4e}")


```
添加到CNN
```python
class CNN(nn.Module):
    def __init__(self, num_class, channels, high, weight):
        super().__init__()
        h = high // 4
        w = weight // 4
        linear_1 = int(128 * h * w)

        self.features = nn.Sequential(
            nn.Conv2d(channels, 32, 3, 1, 1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(32, 128, 3, 1, 1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2)
        )
        self.classifier = nn.Sequential(
            nn.Linear(linear_1, 64),
            nn.ReLU(),
            nn.Linear(64, num_class)
        )

    def forward(self, x):
        # Conv1
        x = self.features[0](x)
        x.register_hook(lambda g: check_grad("Conv1", g))

        x = self.features[1](x)
        x = self.features[2](x)

        # Conv2
        x = self.features[3](x)
        x.register_hook(lambda g: check_grad("Conv2", g))

        x = self.features[4](x)
        x = self.features[5](x)

        x = x.view(x.size(0), -1)
        out = self.classifier(x)
        return out

```
### tensor_hook
作用于张量的钩子 每次计算张量的梯度时触发

hook函数
```python
hook_fn(grad)
```

注册函数
```python
register_hook(hook_fn)
```

#### 例子

