# CUDA
GPU的编程与我们普通CPU是 **不太相同** 的.

具体而言: 因为GPU的 **核心数量** 太多了, 所以GPU的优化基本围绕着 用 **多线程解决** 问题.

我们传统的CPU是这样的:

- 可能几十,上百个核心(cores) 甚至数千个核心.
- 每个核心可能有几个线程(threads) 比如intel的超线程
- 然后每个核有自己的寄存器和缓存
- 也会有L2缓存 和 共享的L3

因为 **核心数量少** 所以CPU有很多的机制来确保: 让少量的进程尽可能的块.

GPU的目标是: **同一种操作 如何应对海量数据**

GPU是这样的: 

- 几十,上百个SM
- 每个SM可以管理大量的warps
- 一个warp通常有32个threads
- 每个SM有自己的 寄存器 L1
- 通常共享L2
- 最后有个很大的VRAM/HBM
## GPU架构
### SM
`SM` 是 GPU的小型计算单位.

因为GPU不可能 **细化的** 去管理 **每一个threads** 所以它需要通过:

- SM 管理 Warp, Warp 管理 threads
- SM 管理 其他的计算单元

```
SM -> Warp / CUDA Cores / Tensor Cores
```


- `Warp`是用来管理与调度 `threads`的.

当然, `SM`与`Warp` 是**硬件层面**的抽象 实际上CUDA提供给我们的接口是 `Grid` 与 `Block`.

- `CUDA Cores` 就是用来计算的 比如整数加法 浮点之类的
- `Tensor Cores` 专门用来矩阵运算的 尤其擅长FP16 BF16等

### 内存层级
GPU的**内存层级**也与CPU不太相同.

每个`threads` 有自己的寄存器 `L1` `L2` 和 `VRAM`

其中共享的内存是 一个 **Block内的所有threads共享的** 所以 如何分配blocks以及它们的内存通信 是**至关重要**的优化问题.

在模型训练的时候 权重 , `KV Cache`, 梯度 大多都放在 VRAM

VRAM就相当于是CPU的RAM.
## Cuda架构
CUDA的API大致分为几类:

- Device管理
- 内存管理
- CPU与GPU的数据传输
- Kernel执行
### Device管理
- `cudaGetDeviceCount(int* count)`: 获取GPU数量
- `cudaSetDevice(int gpu)`: 设置使用哪个GPU
- `cudaGetDeviceProperties(cudaDeviceProp* prop,int gpu)`: 获取指定gpu的信息
- `cudaDeviceReset()`: 重置当前gpu 释放资源
- `cudaDeviceSynchronize()`: 等待当前gpu上任务全完成

### 内存管理
- `cudaMalloc(void** devPtr, size_t size)`: 在gpu上分配指定大小的显存
- `cudaFree(void* devPtr)`: 释放显存
- `cudaMemSet(void* devPtr,int value,size_t count)`: 将指定区域设定为某个值

### Grid/Block
`Grid`与`Block`是 CUDA暴露给我们管理threads的层级.

`Grid`管理`Block`, `Block`管理`threads`.

注意, 由于GPU架构实际上是SM与Warp, 所以我们必须要考虑 **硬件资源对齐**

这个有点像CPU的那个**三级缓存命中**.

因为假设你的`threads` 是 250 个 那么会分配 8个 `Warp`, 前7个是满的 但是最后一个只有26个`threads`.
