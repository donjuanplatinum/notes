# GNU Mach
GNU Mach是GNU Hurd所使用的内核 它是一个**微内核** 而且是第一代的微内核. 它提供 `IPC` 机制 来定义接口.

>IPC机制对Mach非常重要

由于内核中基本用IPC通信 所以`Glibc`的实现是和linux **非常不同**的. Mach提供的核心不是syscall 而是**一些抽象** 这些抽象使得 **外部分页机制**成为可能: 

- 以task形式存在的 **虚拟地址(VA)空间**
- 以thread形式的执行上下文
- IPC
- 以port形式的功能capbility与内存对象
## 虚拟地址空间
虚拟地址空间就是`Task`可以使用的有效虚拟地址. 

每个任务只有一个地址空间，每个地址空间也只属于一个任务.

Task 拥有一个 **虚拟地址空间**；`Thread` 在里面执行； **虚拟地址空间** 又被划分成 Page ,Page 可以通过 Mach 的 VM 机制进行保护、共享、复制、换出.

### Page
虚拟地址空间被划分为不同的Page.

每个Page都有自己的属性, 例如 **访问权限** **继承属性(inheritance)** 以及一些其他的系统属性.

继承属性描述了: 当一个Task**创建/派生**出另一个Task时 ,Page的处理方式

- 无继承
- Copy
- Shared

#### Wired Page
固定界面

固定界面指的是 **无法被换出的** 界面. 这意味着 这个 Page **必须一直留在物理内存** 不能被换出去.

所以 整个 Mach内核都是Wired的
#### Precious Page
宝贵界面

Precious Page指的是 即便被标记`Clean` 但不能被系统静默丢弃的Page. 

在很多情况下,RAM资源紧张时 有**副本**的Clean的Page可能会被discard. 而Precious Page对应没有副本的Page, 它们不应被Discard 否则无法恢复.



### 内存对象
内存对象存放着 **虚拟地址空间** 中 虚拟内存区域的内容.

一个模型为:

- Thread 访问虚拟地址 ----> Task的虚拟地址空间 -----> 内存对象 -----> 内存管理器/Pager -----> 磁盘/文件/网络/或者其他的

> 因此RAM在Mach抽象中 更像一个 Cache.

这些内存对象 **由内存管理器**或者叫`Pagers` 管理, 这些管理器可以实现为 **用户空间** 进程.

#### Pager
告诉Mach 内存对象中的Page内容应该如何 取得/保存.

Pager是可以实现为 **用户空间** 的. 这与传统UNIX内核完全不太一样.

Pager负责处理 `Memory Object`的 Page-in 与Page-Out
所以 Pager 的实现性能对 VM 系统整体性能非常重要

## Task
Mach的Task是 **一组资源** **一个虚拟地址空间** 和 一个 **port 命名空间**的集合, 它们依赖于 `thread` 来执行程序代码.

> **注意 task本身不执行代码**, thread负责执行代码. Task本质是**资源容器** 而 thread是**执行实体**.

传统的UNIX布局 将很多的概念放在了 **进程**.

UNIX进程:

- 虚拟地址空间
- 文件描述符
- 信号量
- PID
- threads

但是Mach将它拆开了:

- 虚拟地址空间
- port的命名空间
- 一些资源
- threads

任务**切换** 所需要的 **上下文切换** 是**昂贵**的.
## Port and IPC
Port是`capability`, 类似于UNIX的pipe, 但是 **不可篡改** 且由内核队列实现.

`Task`,`Thread`,`内存对象 Memory Object`,`Pager`全都可以由Port机制串起来

流程为: 当客户端获得`send right`后,客户端使用port名去发送message(send-once发一条). 这些消息会入队到队列中, 服务端thread 使用`receive right`来获取这个消息.

- 每个port都关联一个 `revice right` 和 一个或多个 `send right` 以及`send-once right`.
- 不同的right是不同的capability.
- 内核队列可以容纳若干`message` 若队列满了会发生阻塞 直到有空间将消息放入队列(可以被超时机制中断)
- `receive right`指定一个队列 并**授权** 持有者从队列中**取出消息** 然后创建`sned right` 和`send-once right`
- `send right`和`send-once right`  指定一个队列并**授权**持有者 **放入信息**
- 每个`Task`都关联着一个port的**地址空间**. 所有Port都通过此表进行寻址
- `port right`本身 也可以被`delegation`
- 消息队列的顺序是严格有序的
### port set
一个`thread`只能阻塞单个port的接收操作. 为了解决这个问题 引入了`port set`.

`port set`将多个`receive right` 合并成了一个可等待的入口.
### message
Message是具有 **布局** 的类型化的数据的一个容器 它包含一个`ID`.

Message用于mach的IPC机制 通过ports 使用`match_msg`接口 发送与接收.

Message是**不透明**的 而且可以包含传递给其他`task`的`port right`

> port right 可以 copy或者move, 但是port receive right **必须move**. 因为一个port的receive right **只能由一个任务持有**.

消息中的某些数据可能是**外部数据**, 也就是对 `memory object`的引用.

当`Task`接收到消息时 
## Capability
`Capability`是一种**受保护的引用**. 机制有点类似Rust的所有权.

`Capability`指向一个**无法伪造的对象**, 而且具有操作该对象的**权限**.

传统的UNIX将 对象的身份 与 对象的权限 分开了, 然而在Mach, 具有Capability 本身意味着可以操作这个对象.

最经典的有 Mach的核心机制 Port机制 也是Capability模型: port right是capability 而port是 capability指向的对象.
### delegation
假设A有文件F, A想把 读取F的权限给B. 那么A可以直接把 read的capability给B 这个过程叫delegation.


## 外部分页机制
Mach的外部分页机制使得 **内存管理与内容管理分离**: Mach负责 **内存管理** 而 **用户空间** 负责 **内容管理**.

> 这个分离对于理解Mach的**外部分页机制**的抽象与理念至关重要

## Thread
## Translator

