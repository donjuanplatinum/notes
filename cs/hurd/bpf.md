# BPF过滤器实现
在HURD中 目前 `1dbc5f61`中 BPF的实现为`cBPF` 即传统BPF.

在Hurd里, BPF承担的作用会和Hurd的微内核架构的IPC紧密结合.

它决定了一个网络包最终应该被送到哪个Mach `receive port`.
## BPF过滤器
BPF最初是 Berkeley Packet Filter 就是用来**过滤网络包的过滤器**.

在UNIX中cBPF(classic BPF)的执行位于**内核态**.

而在Hurd中cBPF是hurd的用户态实现.

BPF使用了一种基于**寄存器**的虚拟机.
### ISA指令集架构

BPF两种ISA: 

- 基本指令编码 64bit.
- 宽指令编码, 也就是两个64bit 一共128bit.


#### 基本指令编码
也就是64bit的编码

```
|opcode 8bit|regs 8bit|offset 16bit|imm 32bit|
```

> **Linux内核文档明确要求,未使用的字段必须置0**

- `opcode`: 操作码 

操作码的组成如下:

```
|specific 5bit|class 3bit|

```
    - `specific`: 这些位的意义定义于不同的`instruction class`
    - `class`: 指令类别
- `regs`: 源和目标寄存器的号码

regs组成如下:

```
|dst_reg|src_reg| # big-endian
|src_reg|dst_reg| # little-endian, 常见PC都是little-endian x86-64, arm64
```
	- `src_reg`: 源寄存器的号码(0-10), 64bit的imm指令集对这个字段有其他用处
	- `dst_reg`: 目标寄存器号码(0-10)
- `offset`: 指针运算中使用的有符号偏移量 相当于`i16`
- `imm`: 立即数 是个`i32`

#### 宽指令编码
宽指令编码由**两条基本指令编码**组成.

第一条是基本指令编码 第二条除了`imm`都是0.

也就是说 宽指令编码有两个`imm` i32.

#### instruction class
`opcode`的`class`占3bit.

| class | val | descri                  |
|-------|-----|-------------------------|
| LD    | 0x0 | 从内存/特殊来源load     |
| LDX   | 0x1 | 从内存加载到寄存器      |
| ST    | 0x2 | imm写入内存             |
| STX   | 0x3 | 把寄存器写入内存        |
| ALU   | 0x4 | 32bit 算术/逻辑         |
| JMP   | 0x5 | 32bit 条件/无条件控制流 |
| JMP32 | 0x6 | 32bit 比较跳转          |
| ALU64 | 0x7 | 64bit 算术/逻辑                        |
##### 算术与跳转
对于 `ALU` `JMP` 系列, `opcode`分为三个部分：

```
| code 4bit| src 1bit| class 3bit|
```

- `code`: 操作码
- `src`: 0代表使用imm作为源操作数; 1代表使用`src_reg`作为操作数


`code`操作码:

| code  | val | offset  | op                                                                                | descrip      |
|-------|-----|---------|-----------------------------------------------------------------------------------|--------------|
| ADD   | 0x0 | 0       | dst += src                                                                        | 加           |
| SUB   | 0x1 | 0       | dst -= src                                                                        | 减           |
| MUL   | 0x2 | 0       | dst *= src                                                                        | 乘           |
| DIV   | 0x3 | 0       | dst = (src !=0) ? (dst/src) : 0                                                   | 有符号除     |
| SDIV  | 0x3 | 1       | dst = (src ==0) ? 0 :((src == -1 && dst == LLONG_MIN) ? LLONG_MIN : (dst s/ src)) | 无符号除     |
| OR    | 0x4 | 0       | dst \|= src                                                                       | 或           |
| AND   | 0x5 | 0       | dst &= src                                                                        | 与           |
| LSH   | 0x6 | 0       | dst <<= (src & mask)                                                              | 左移         |
| RSH   | 0x7 | 0       | dst >>= (src & mask)                                                              | 逻辑右移     |
| NEG   | 0x8 | 0       | dst = -dst                                                                        | 取负         |
| MOD   | 0x9 | 0       | dst = (src != 0) ? (dst % src) : dst                                              | 无符号取模   |
| SMOD  | 0x9 | 1       | dst = (src == 0) ? dst : ((src == -1 && dst == LLONG_MIN) ? 0: (dst s% src))      | 有符号取模   |
| XOR   | 0xa | 0       | dst ^= src                                                                        | 异或         |
| MOV   | 0xb | 0       | dst = src                                                                         | 复制src到dst |
| MOVSX | 0xb | 8/16/32 | dst = (s8,s16,s32)src                                                             | 符号拓展     |
| ARSH  | 0xc | 0       | sign extending dst >>= (src & mask)                                               | 算术右移     |
| END   | 0xd | 0       | 字节交换操作                                                                      | 字节交换     |


边界行为规约:

- 算术运算允许 **下溢** 与 **溢出**.
- 如果除0 那么`dst_reg`会被设置为0.
- ALU64 如果 `LLONG_MIN` 除以-1, 那么`dst_reg`置为`LLONG_MIN`
- ALU 如果`INT_MIN`除以-1, 那么`dst_reg`置为`INT_MIN`
- 如果 `MOD`了0, 那么ALU64的`dst_reg`不变.
- 如果 `MOD`了0, 则ALU的`dst_reg`的高32位 置为0.
- 如果 是 `LLONG_MIN` `MOD`了 -1 或者 `INT_MIN` `MOD` 了 -1, `dst_reg`都置为0.
##### 字节交换指令END
## hurd实现
- `hurd/libbpf/`: cBPF的**用户态**实现
- `gnumach/device/net_io.c`: Mach的**内核侧**实现
- `gnumach/device/net_io.h`
- `gnumach/include/device/bpf.h`

### 流程

GNU Mach在受到packet后, 核心流程是:

1. 网络设备
2. 执行net_filter()
3. 选择输入或输出过滤器队列
4. bpf_do_filter()
5. 返回需要投递的字节数
6. 复制到目标 Mach receive port
### queue
BPF要用到的**双向链表**.

`hurd/libbpf/queue.h`
`hurd/libbpf/queue.c`

双向链表.
```c
struct queue_entry {
	struct queue_entry	*next;		/* next element */
	struct queue_entry	*prev;		/* previous element */
};

typedef struct queue_entry	*queue_t;
typedef	struct queue_entry	queue_head_t;
typedef	struct queue_entry	queue_chain_t;
typedef	struct queue_entry	*queue_entry_t;
```
### if_filter_list_t
每个网络接口维护两类过滤器**队列** 定义于`hurd/libbpf/bpf_impl.h`:

- 输入过滤器: `if_rcv_port_list`
- 输出过滤器: `if_snd_port_list`

```c
typedef struct
{
  queue_head_t if_rcv_port_list;	/* input filter list */
  queue_head_t if_snd_port_list;	/* output filter list */
} if_filter_list_t;
```


#### net_rev_port
每个队列的对象是 `net_rev_port_t`

```c
/*
 * Receive port for net, with packet filter.
 * This data structure by itself represents a packet
 * filter for a single session.
 */
struct net_rcv_port {
	queue_chain_t	input;		/* list of input open_descriptors */
	queue_chain_t	output;		/* list of output open_descriptors */
	mach_port_t	rcv_port;	/* port to send packet to */
	int		rcv_count;	/* number of packets received */
	int		priority;	/* priority for filter */
	filter_t	*filter_end;	/* pointer to end of filter */
	filter_t	filter[NET_MAX_FILTER];
	/* filter operations */
};
```

其中: 

- `rev_port`: 匹配成功后 投递到的Mach Port.
- `priority`: 过滤器优先级
- `filter[]`: 过滤器程序
- `filter_end`: 程序结束位置
