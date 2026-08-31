# BPF过滤器实现
`hurd/libbpf/bpf_impl.c`

## BPF过滤器
BPF最初是 Berkeley Packet Filter 就是用来**过滤网络包的过滤器**.

在UNIX中cBPF(classic BPF)的执行位于**内核态**.

而在Hurd中cBPF是hurd的用户态实现.

### cBPF模型
一条指令的结构如下:

总共64bits

- code: 16bits, 代表指令 比如`LD` `ST` `ADD` `JEQ`
- jt: 8bits, 告诉`jump`要跳多少指令 当`jump`条件成立时
- jf: 8bits, 告诉`jump`要跳多少指令 当`jump`条件失败时
- k: 32bits, 具体含义与`code`相关

比如指令: `LD[12]` :

```
code = BPF_LD | BPF_W | BPF_ABS
jt = 0
jf = 0
k = 12
```


解释器的核心状态如下:

- A: accumulator 累加器 计算寄存器
- X: index register 间接寻址
- M[0..15]: scratch memory 临时变量区 
- PC: program counter

```c
unsigned int A, X;
int k;
unsigned int mem[BPF_MEMWORDS];

```

