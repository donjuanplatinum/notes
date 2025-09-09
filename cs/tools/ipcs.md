# ipcs
显示IPC信息

信息来源: `/proc/sysvipc/*`

## sysvipc
SysV IPC 是一套基于 System V 标准 的经典进程间通信（IPC）机制

SysV IPC 包含三大核心机制，各自针对不同的通信场景：消息队列（Message Queues）、共享内存（Shared Memory）、信号量（Semaphores）

三者均通过 “键（Key）” 和 “标识符（ID）” 进行管理，且生命周期独立于创建进程（除非显式删除，否则会持续存在于系统中）。

### Message Queues
消息队列

消息队列是一种 “异步通信” 机制：进程可以向队列中发送 “带类型的消息”，其他进程则按类型或顺序从队列中接收消息，无需双方同时运行。

