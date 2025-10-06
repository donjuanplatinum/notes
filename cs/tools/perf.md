# Perf
## TracePoint
`linux/include/linux/tracepoint.h`
tracepoints是散落在内核源码中的一些hook

## command
perf的二级命令

 1  annotate  解析perf record生成的perf.data文件，显示被注释的代码。  
 2  archive  根据数据文件记录的build-id，将所有被采样到的elf文件打包。利  
     用此压缩包，可以再任何机器上分析数据文件中记录的采样数  
     据。  
 3  bench  perf中内置的benchmark，目前包括两套针对调度器和内存管理子  
     系统的benchmark。  
 4  buildid-cache  管理perf的buildid缓存，每个elf文件都有一个独一无二的buildid。  
     buildid被perf用来关联性能数据与elf文件。  
 5  buildid-list  列出数据文件中记录的所有buildid。  
 6  diff  对比两个数据文件的差异。能够给出每个符号（函数）在热点分  
     析上的具体差异。  
 7  evlist  列出数据文件perf.data中所有性能事件。  
 8  inject  该工具读取perf record工具记录的事件流，并将其定向到标准输  
     出。在被分析代码中的任何一点，都可以向事件流中注入其它事  
     件。  
 9  kmem  针对内核内存（slab）子系统进行追踪测量的工具  
 10  kvm  用来追踪测试运行在KVM虚拟机上的Guest OS。  
 11  list  列出当前系统支持的所有性能事件。包括硬件性能事件、软件性  
     能事件以及检查点。  
 12  lock  分析内核中的锁信息，包括锁的争用情况，等待延迟等。  
 13  mem  内存存取情况  
 14  record  收集采样信息，并将其记录在数据文件中。随后可通过其它工具  
     对数据文件进行分析。  
 15  report  读取perf record创建的数据文件，并给出热点分析结果。  
 16  sched  针对调度器子系统的分析工具。  
 17  script  执行perl或python写的功能扩展脚本、生成脚本框架、读取数据文  
     件中的数据信息等。  
 18  stat  执行某个命令，收集特定进程的性能概况，包括CPI、Cache丢失  
     率等。  
 19  test  perf对当前软硬件平台进行健全性测试，可用此工具测试当前的软  
     硬件平台是否能支持perf的所有功能。  
 20  timechart  针对测试期间系统行为进行可视化的工具  
 21  top  类似于linux的top命令，对系统性能进行实时分析。  
 22  trace  关于syscall的工具。  
 23  probe  用于定义动态检查点。  

### list
perf list可以显示本机支持的事件类型 
```
hw/cache/pmu为硬件相关事件 tracepoint为内核事件 sw是内核计数器
hw/hardware显示支持的硬件事件列表
sw/software显示支持的软件事件列表
cache/hwcache显示硬件cache相关事件
pmu显示支持的PMU事件列表
tracepoint显示支持所有的tracepoint列表
```
### top
1 第一列：符号引发的性能事件的比例，指占用的cpu周期比例。

2 第二列：符号所在的DSO(Dynamic Shared Object)，可以是应用程序、内核、动态链接库、模块。

3 第三列：DSO的类型。[.]表示此符号属于用户态的ELF文件，包括可执行文件与动态链接库；[k]表述此符号属于内核或模块。

4 第四列：符号名。有些符号不能解析为函数名，只能用地址表示。
* 关于perf top界面常用命令如下：

  h: 帮助
  a: 注解当前符号 能够给出汇编语言的注解 给出各条指令的采样率
  d: 过滤掉不属于此DSO的符号 非常方便查看同一类别的符号
  P: 保存到perf.hist.N
  e: 在-g中展开函数调用
  E: 展开所有
  V: 显示库的路径
  
* perf top常用选项有：

 -e <event>：指明要分析的性能事件。 
 -p <pid>：Profile events on existing Process ID (comma sperated list). 仅分析目标进程及其创建的线程。
 -k <path>：Path to vmlinux. Required for annotation functionality. 带符号表的内核映像所在的路径。 
 -K：不显示属于内核或模块的符号。
 -U：
 不显示属于用户态程序的符号。
 -d <n>：界面的刷新周期，默认为2s，因为perf top默认每2s从mmap的内存区域读取一次性能数据。
 -g：得到
 函数的调用关系图。

* perf top --call-graph [fractal]，路径概率为相对值，加起来为100%，调用顺序为从下往上。

* perf top --call-graph graph，路径概率为绝对值，加起来为该函数的热度。
### stat
cpu-clock：任务真正占用的处理器时间，单位为ms。CPUs utilized = task-clock / time elapsed，CPU的占用率。
context-switches：程序在运行过程中上下文的切换次数。
CPU-migrations：程序在运行过程中发生的处理器迁移次数。Linux为了维持多个处理器的负载均衡，在特定条件下会将某个任务从一个CPU迁移到另一个CPU。
CPU迁移和上下文切换：发生上下文切换不一定会发生CPU迁移，而发生CPU迁移时肯定会发生上下文切换。发生上下文切换有可能只是把上下文从当前CPU中换出，下一次调度器还是将进程安排在这个CPU上执行。
page-faults：缺页异常的次数。当应用程序请求的页面尚未建立、请求的页面不在内存中，或者请求的页面虽然在内存中，但物理地址和虚拟地址的映射关系尚未建立时，都会触发一次缺页异常。另外TLB不命中，页面访问权限不匹配等情况也会触发缺页异常。
cycles：消耗的处理器周期数。如果把被ls使用的cpu cycles看成是一个处理器的，那么它的主频为2.486GHz。可以用cycles / task-clock算出。
stalled-cycles-frontend：指令读取或解码的质量步骤，未能按理想状态发挥并行左右，发生停滞的时钟周期。
stalled-cycles-backend：指令执行步骤，发生停滞的时钟周期。
instructions：执行了多少条指令。IPC为平均每个cpu cycle执行了多少条指令。
branches：遇到的分支指令数。branch-misses是预测错误的分支指令数。

-e 指定events
### bench
benchmark

perf bench sched：调度器和IPC机制。包含messaging和pipe两个功能。
perf bench mem：内存存取性能。包含memcpy和memset两个功能。
perf bench numa：NUMA架构的调度和内存处理性能。包含mem功能。
perf bench futex：futex压力测试。包含hash/wake/wake-parallel/requeue/lock-pi功能。
perf bench all：所有bench测试的集合
### trace
追踪
### record
-e record指定PMU事件
--filter event事件过滤器
-a 录取所有CPU的事件
-p 录取指定pid进程的事件
-o 指定录取保存数据的文件名
-g 使能函数调用图功能
-C 录取指定CPU的事件
### report
解析record产生的数据
### kmem
perf kmem用于跟踪测量内核slab分配器事件信息。
比如内存分配/释放等。可以用来研究程序在哪里分配了大量内存，或者在什么地方产生碎片之类的和内存管理相关的问题。
### probe
（用户空间探测）是在运行时监控用户空间应用程序中特定点的动态检测机制，而无需更改源代码或重新编译。

## Examples
### 查看IPC
```
perf stat -e cycles,instructions COMMAND
```

### 查看程序中性能
```
perf record COMMAND
perf annotate
```
### 类似strace

查看系统调用对应events
```
sudo perf list |grep -i syscalls
```

系统调用特殊events
```
raw_syscalls:sys_enter // 系统调用进入
raw_syscalls:sys_exit // 系统调用退出
vsyscall:emulate_vsyscall // vsyscall机制的仿真执行
```
追踪
```

```
