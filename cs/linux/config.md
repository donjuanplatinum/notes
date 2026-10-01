# 内核配置
## MM
内存管理子系统
### NUMA_MIGRATION
NUMA内存迁移.

当使用NUMA时,若 node 0的进程经常访问node 1的memory, NUMA迁移会把node 1的Page迁移过来.
## PREEMPT
内核抢占模型

从`PREEMPT_NONE` -> `PREEMPT_VOLUNTARY` -> `CONFIG_PREEMPT`, 抢占越来越积极

- `PREEMPT`的三个是 **完全抢占** 如果要抢占就尽快抢占.
- `PREEMPT_LAZY`是 先标记抢占 如果要抢占 等到合适的时候抢占.
- `PREEMPT_RT`和前面两个不一样,前两种调度的平均latency很好,但可能偶尔出现一个很大的lantency.

RT对最坏复杂度做了防范.

RT做了非常多的改造来防止这种情况: 比如spinlock变成可睡眠与被抢占, IRQ调度改造等.
### PREEMPT_NONE
通常不会抢占
### PREEMPT_VOLUNTARY
内核的一些位置有`cond_resched`, 这些位置代表: 如果有高优先级的任务 可以考虑调度.

开启这个选项代表 如果有这些位置 可以考虑调度
### CONFIG_PREEMPT
只要当前执行位置允许抢占, scheduler 可以更积极地让出 CPU.


### PREEMPT_LAZY
### CONFIG_PREEMPT_DYNAMIC
编译内核后 可以在启动的cmdlien指定不同的抢占行为.
### CONFIG_PREEMPT_RT
## sched
调度器

### CONFIG_SCHED_CORE
### CONFIG_SCHED_CLASS_EXT
### CONFIG_FAIR_GROUP_SCHED
### CONFIG_EXT_GROUP_SCHED
### CONFIG_EXT_SUB_SCHED
