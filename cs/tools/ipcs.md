# ipcs
显示IPC信息

信息来源: `/proc/sysvipc/*`

## 使用
```
ipcs -l # 实现SYSV IPC的系统限制
ipcs # 列出msg,shm,sem
ipcrm -q / -m / -s # 删除指定标识符的消息队列/共享内存段/信号量集
ipcrm -Q / -M / -S # 删除指定键值的消息队列/共享内存段/信号量集
```
## sysvipc
SysV IPC 是一套基于 System V 标准 的经典进程间通信（IPC）机制

SysV IPC 包含三大核心机制，各自针对不同的通信场景：消息队列（Message Queues）、共享内存（Shared Memory）、信号量（Semaphores）

三者均通过 “键（Key）” 和 “标识符（ID）” 进行管理，且生命周期独立于创建进程（除非显式删除，否则会持续存在于系统中）。

### Message Queues
消息队列

消息队列是一种 “异步通信” 机制：进程可以向队列中发送 “带类型的消息”，其他进程则按类型或顺序从队列中接收消息，无需双方同时运行。

由Linux msg系列系统调用创建

### Shared Memory
由linux shm系列系统调用创建

### Semaphores
信号量并非用于传递数据，而是一种 “进程同步与互斥” 工具：通过一个或一组 “计数器” 控制对共享资源（如共享内存、文件）的访问，防止多个进程同时操作导致的数据竞争。

由linux sem系列系统调用创建

### kEY与ID
SysV IPC 的三大组件均通过 “键” 和 “标识符” 实现进程间的关联，这是其区别于其他 IPC 机制的核心特性。

#### 键（Key）：IPC 对象的 “名字”

键是一个 key_t 类型的整数（通常为 32 位），用于唯一标识系统中的一个 IPC 对象（消息队列、共享内存、信号量集），相当于 IPC 对象的 “全局名字”。

#### 标识符（ID）：IPC 对象的 “句柄”
标识符是进程访问 IPC 对象的 “句柄”，由内核在 msgget()/shmget()/semget() 调用时返回（如 msgid、shmid、semid）。
