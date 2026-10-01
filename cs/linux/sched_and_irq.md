# 调度与中断
- 调度器决定 在某个CPU上 接下来哪个task使用CPU.
- irq负责处理中断.
## 调度与中断
Linux中 CPU执行的东西主要有两大类

1. task
2. interrupt

其中task就是 **调度器** 进行调度的对象. 它的结构为`task_struct`

> **sched不止调度进程 它调度所有实现了task_struct的抽象**.

而中断不太一样, 中断是CPU的执行流被硬件/异常机制 转入到内核处理流程. **它不属于task**.

### 调度
sched要解决主要三个问题

- 什么时候**重新调度**: trigger
- 要不要**抢占**当前task: preempt
- 下一个task选谁: policy

根据不同的 **生产环境**, 调度的策略都不太一样. Linux内核的**调度类**是模块化的, 可以选择不同的调度器.

Linux内核按照调度器的优先级 调用不同的调度器.


#### 调度器类
有如下调度器类

1. `stop_sched_class`: 停止CPU的特殊任务
2. `dl_sched_class`: deadline 截止时间调度
3. `rl_sched_class`: 实时real time调度
4. `fair_sched_class`: 完全公平调度
5. `ext_sched_class`: 可拓展调度
6. `idel_sched_class`: 空闲任务调度

其中: 

- stop_sched_class是内核特殊用途的
- fair代表公平,目的是公平的分配CPU 尽量让每个进程合理的得到公平的分配.
- rt代表实时 是一种比较特殊的任务情况,它并不追求**平分** 而追求 最差的延迟不能太差.
- deadline代表 任务具有deadline,它更关注任务能不能在ddl之前完成,相当于不想挂科的大学生
- idel调度策略是CPU没有其他runnable task时使用的
- sched_ext是给其他内核模块 比如eBPF用的

> 注意: **同一机器上可以同时存在不同的调度策略.**

比如: 浏览器 用EEVDF, 音频用RT, 严格周期任务用DDL.
#### 调度器实现
##### stop_sched_class
##### fair_sched_class
目前的linux 7.3左右一直用的是 **EEVDF**. 但是 历史上的CFS 我们也会讲解 因为很经典.

CFS算法统治了内核很久 大概07年,而24年EEVDF取代了CFS.

CFS只追求绝对公平,而EEVDF在公平的基础上引入了 延迟控制.

1. CFS

CFS的目的是 每个task按照自己的`weight` 按比例分配到公平的CPU执行时间.

weight与进程的nice值是一个映射关系,大概是指数关系.

CFS引入了一个概念: **vruntime**. 也就是说: 这个task按照公平的规则,已经消费了多少CPU.

sched倾向于选择 vruntime最小的进程,因为它跑的最少.

那么权重的体现为: 权重越大 vruntime增长越慢.

其实说白了: **vruntime就是把不同weight的进程的执行时间统一到一个度量**

那为什么不用除法呢? 因为除法要考虑浮点 进位什么的 麻烦些. 乘法全是整数 非常不错.

数据结构方面 CFS用了红黑树 然后最左边的最小值 cache一下,就得到了O(1)的取出,O(logN)的插入.

2. EEVDF

24年EEVDF进入主线.

CFS是,谁的vruntime最小 谁就跑. 而EEVDF引入了两个新的概念 把dl_sched_class的思想加进来了一些:

`lag`(滞后量) 与 `virtual ddl`(虚拟截止时间).

EEVDF将调度拆成了两个问题: 这个task现在能不能运行 与 有资格运行的task里面谁最先运行.

lag = 应该获得的CPU时间(类似CFS的vruntime) - 实际上获得的CPU时间

lag > 0, 它有资格获取更多的CPU; 否则它跑多了.

virtual ddl 相当于: 如何改按照理想的公平调度 这个task的这份cpu时间应该什么时候完成.

这个时候`ddl_sched_class`的一些思想就来了: EDF: ddl越早优先级越高

一句话理解就是: **在lag > 0的task里 通过EDF找到优先级最高的**.

##### rt_sched_class

实时调度类有两个policy: `SCHED_FIFO` 与 `SCHED_RR`.

- `SCHED_FIFO`代表 同优先级的任务按FIFO顺序运行
- `SCHED_RR` 同优先级之间使用round-robin(轮询)
##### dl_sched_class

ddl调度类用的是**EDF + CBS**.

###### EDF
最早截至期优先. 哪个任务的 **绝对截止期最早** 就先执行它.

- 动态优先级: 任务的优先级不是固定的 而是随其绝对截止期动态变化的. 截止期越早,优先级越高
- 理论最优性: 在单处理器上,只要任务集的总利用率不超过 1, EDF 就能保证所有任务都满足截止期.因此,它常被视为单核实时调度的黄金标准.
- 局限性: EDF 本身不限制单个任务的行为. 如果某个任务发生超时, 它可能挤占其他任务的时间,导致其他任务错过截止期.
###### CBS
恒定带宽服务器. CBS正是为了解决EDF的缺陷.

具体来讲 它是一种 资源预留协议: 为每个任务提供一个受控的执行环境,确保其行为不会影响其他任务.

CBS有两个核心参数: 预算Q 与 周期P.

- 每个周期P内, 被CBS管理的任务最多只能运行Q个单位的时间.
- 当task用完了它的Q后 就会被 **节流**, 暂停执行 直到下一个周期得到补充
- $\frac{Q}{P}$ 称为服务器的带宽 代表它为任务预留CPU的能力比例.
###### EDF+CBS
Linux的DEADLINE调度策略就是EDF与CBS的结合:

- CBS负责管住任务, 为每个任务设置一个带宽. 超出预算就暂停
- EDF负责排序任务 EDF负责找到截止期最早的任务执行
## task_struct
定义于`include/linux/sched.h`.

它里面的成员很多,大概有:

1. 调度相关的状态: 比如优先级, 调度实体 ,调度类, 调度策略, 可以在什么CPU上跑之类的.
2. 身份与生命周期: pid,gid,子进程..
3. 内存管理: 当前task的用户地址空间,栈指针 ,各种NUMA相关,各种内存统计,OOM相关,TLB什么的
4. 文件系统: 打开了什么文件,块设备IO链表,io_uring之类的.
5. 信号与IPC
6. 权限
5. 给内核其他机制用的: ptrace状态 , cgroup 之类的
## sched_class
调度类 定义于 `kernel/sched/sched.h`

调度类实现的接口 大概有如下的方法.

```c
struct sched_class {
    // 任务入队/出队
    void (*enqueue_task)(struct rq *rq, struct task_struct *p, int flags);
    bool (*dequeue_task)(struct rq *rq, struct task_struct *p, int flags);

    // 选择下一个要运行的任务
    struct task_struct *(*pick_task)(struct rq *rq, struct rq_flags *rf);

    // 检查是否需要抢占
    void (*wakeup_preempt)(struct rq *rq, struct task_struct *p, int flags);

    // 周期性时钟tick处理
    void (*task_tick)(struct rq *rq, struct task_struct *p, int queued);

    // 负载均衡
    int (*balance)(struct rq *rq, struct rq_flags *rf);

    // 其他操作...
};
```
