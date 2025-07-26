# 专有名词

## Linux内核

### DSO
Dynamic Shared Object 是 Linux/Unix 系统中动态链接库的实现形式

### PMU
Performance Monitoring Unit 性能监控单元

以极低的开销收集处理器内部的详细性能数据

### IPC
Instructions Per Cycle 每周期指令数

表示每个时钟周期内平均执行的指令数

$$
IPC = \frac{执行指令数(Instructions)}{消耗周期数(Cycles)}
$$
### IRQ
Interrupt ReQuest 来自设备的中断请求

IRQ编号是用来描述硬件中断源的内核标识符 通常它是一个到全局irq_desc数组的索引， 但是除了在linux/interrupt.h中实现的之外，其它细节是体系结构特征相关的。

IRQ编号是对机器上可能的中断源的枚举
### SMP
Symmetric Multi-Processing 对称多处理

操作系统支持多个处理器对称地共享系统资源且并行执行任务的技术
### ACPI
Advanced Configuration and Power Interface 高级配置与电源接口 

管理计算机硬件的电源状态、配置、热管理、性能调节等
### vDSO
Virtual Dynamic Shared Object 虚拟动态共享对象

Linux 内核提供的一种高效系统调用机制，用于优化某些频繁调用的系统调用 用于替代`vsyscall`
 
将某些无副作用、只读、频繁调用的系统调用（如获取时间）直接映射到用户空间 

- 无需进入内核
- 零上下文切换

## 硬件
### SIMD
Single Instruction Multiple Data 单指令多数据流技术

SIMD (Single Instruction, Multiple Data) 是一种并行计算技术，它允许一条指令同时处理多个数据。
## 说话术语
### RTFM
read the fucking manual

通常用于回答基本问题，而这些问题的答案很容易在文档、用户指南、用户手册、手册页、在线帮助、网络论坛、软件文档或常见问题解答中找到。

### LGTM
Looks Good To Me

表示review觉得可以
