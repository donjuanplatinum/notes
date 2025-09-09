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

### MMU
Memory Management Unit 内存管理单元
### KSM
Kernel Samepage Merging 内核同页合并
### RS/RES
Resident Memory 驻留内存

驻留内存，是指被映射到进程虚拟内存空间的物理内存。进程的驻留内存就是进程实实在在占用的物理内存。一般我们所讲的进程占用了多少内存，其实就是说的占用了多少驻留内存而不是多少虚拟内存。因为虚拟内存大并不意味着占用的物理内存大。
### VM
Virtual Memory 虚拟内存

虚拟内存是操作系统内核为了对进程地址空间进行管理（process address space management）而精心设计的一个逻辑意义上的内存空间概念。 虚拟内存是逻辑意义上的内存空间，为了使程序能够在物理内存上运行，需要将虚拟内存映射到物理内存，这一功能由操作系统中页映射表来完成。
## Linux
### KMS
Kernel Mode Setting 内核级显示模式设置

作用是可以在内核级别而不是最终用户级别切换显示分辨率和颜色深度。

Linux 内核的 KMS 实现支持在 framebuffer 中使用原生分辨率和即时终端(tty)切换。KMS 使用了更新的技术(例如 DRI2)，可以减少失真、增强3D性能，甚至使用内核空间节能功能。
### FUSE
Filesystem in UserSpace 用户空间中的文件系统 为用户提供了一种无需特殊权限即可挂载文件系统的方法（Linux 中的挂载通常保留给具有管理权限的用户 ）。
## 硬件
### SIMD
Single Instruction Multiple Data 单指令多数据流技术

SIMD (Single Instruction, Multiple Data) 是一种并行计算技术，它允许一条指令同时处理多个数据。
### ASoC
Advanced Linux Sound Architecture 高级Linux声音架构  Linux 系统中用于处理嵌入式设备音频功能的架构
### DSDT
Differentiated System Description Table  DSDT是ACPI规格的一部分 它提供了关于一个给定系统中受支持的电源事件的信息 通常 Linux遇到的问题是某些ACPI功能的缺失 比如风扇不转 盖子合上时屏幕不熄灭等等 这些问题可以归咎于DSDT是为Windows所定制的 安装后可以打补丁来修复这些问题

基本上来说 一个DSDT表是运行在ACPI(电源管理)上的代码
## 说话术语
### RTFM
read the fucking manual

通常用于回答基本问题，而这些问题的答案很容易在文档、用户指南、用户手册、手册页、在线帮助、网络论坛、软件文档或常见问题解答中找到。

### LGTM
Looks Good To Me

表示review觉得可以
## coding
### UB
Undefined Behavoir 未定义行为
