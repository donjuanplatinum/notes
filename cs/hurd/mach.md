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

当`Task`接收到消息时 , 这些`memory object`会被虚拟复制 被映射到`receive`方的 **虚拟地址空间**. 复制的方式为写时复制COW.
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

传统Linux的分页是:

```c
char *p = mmap(file,...);
x = p[0];
```

访问`p[0]`时, 如果对应**Page** 不在RAM , 会产生`Page Fault` 然后内核去**文件系统** 再通过io什么的 把数据放进**物理页* 最后建立页表映射.

而Mach的思路不一样.

`vm_map` 把一个 `memory object` 映射到 `Task` 的虚拟地址空间；如果这是第一次映射这个 object，Mach 就通过 Mach IPC 联系管理它的 server，并建立一个 `control capability`，使这个 server 将来能够在发生 page fault 时向 Mach 提供相应的 page。这个机制在使用体验上类似 UNIX 的 `mmap`，但 Mach 的 `memory object` 比 UNIX 的文件抽象更加一般。

当`task`发生faults时, Mach将会去检查是否存在`mem obj`关联这个地址. 如果不存在 则会向`task`抛出exception,该exception会进一步传播为`seg fault`; 如果存在, Mach会检查相应的内存页是否在核心内存中.如果在核心内存中,则会安装该内存页 并恢复任务.然后mach会调用`memory_object_request`方法去找`pager`要`mem obj`. pager受到请求后 使用`memory_object_supply`把页面交给mach.

### 创建与映射mem obj
Client 向 Server 请求资源 → Server 创建 memory object，并把代表它的 capability 交给 Client → Client 通过 vm_map 把 memory object 请求映射到自己的地址空间 → Mach 第一次看到该 object 时通知 Server，并给 Server 一个 memory control capability → Server 初始化管理状态并通知 Mach memory_object_ready → Mach 建立映射并返回成功。

1. client 向 server 发送 `open` RPC
2. server 创建 `mem obj` (port receive right), 将它添加到正在监听的`port set`中, 并向client返回一个`capability`(port send right)
3. client尝试使用`vm_map` RPC将`mem obj`映射到它自己的地址空间
4. 因为Mach从未见过这个obj,Mach会使用`memory_object_init`在给定port上排队 并附带一个`send right`(memory control port),这个`send right`用于manager向mach发送信息 同时也做为未来交互的身份验证机制: 提供该port也是为了让manager识别obj来自哪个内核.
5. 服务器将message出队 初始化内部数据结构来管理映射 然后调用`memory_object_ready`控制obj上的方法
6. 内核看到manager准备就绪 在client在地址空间中设置映射 然后用之前得到的port回复RPC成功
### page fault
Client 缺页 → Mach 找到 Pager → Pager 找数据 → 数据变成 page → Pager 把 page 交给 Mach → Mach 映射给 Client。

1. client执行内存访问并发生fault. 内核捕获到fault 并将地址映射到相应的`mm obj`. 然后它调用`capbility`上的`memory_object_request`方法.
2. manager出队这个消息.然后这个消息被转换为`store_read`函数. storeio server以独立进程启动 但如果server拥有相应权限, 则可以直接联系后端对象.
3. storeio server会联系某个设备驱动来执行读取操作. 可以是网络设备 文件 或者 mm obj
4. 设备驱动程序从默认 pager 分配一个匿名page,并将数据读入其中. 操作完成后 将数据返回给client 同时取消地址空间的映射
5. storeio server将page传输给server. 此时该page仍为匿名页
6. manager 使用`memory_object_supply` 将page传输到内核. 此时 该page才被视为受管理的page.
7. 内核cache这个page 将其安装到client的虚拟地址空间 然后恢复客户端
### paging data out
Mach 决定paging out page → 暂时把 page 的管理权交给 Default Pager → Mach 通知原来的 Server 返回 page → Server 保存 page 内容并释放它 → Server 通过 storeio 把数据写入 backing store → device driver 完成写入并释放这块内存。

1. 分页策略被mach实现 ,server只需实现机制
2. 内核一旦选定要paging out的page 就会将manager从server切换到默认的pager. 
3. mach调用 contro object上的`memory_object_return` 通知服务器
4. manager将数据传给storeio server,最终由 storeio服务器将数据发送到磁盘.设备驱动程序消耗内存.
## Thread
## Translator

