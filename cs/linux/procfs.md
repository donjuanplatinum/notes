# Procfs
Linux内核的进程档案文件系统, 你可以在里面查看到许多与**内核**, **调度器**, **中断**, **内核版本**, **进程**相关的内容.

`ps`命令很多情况也是对里面接口的封装.

## 总览
具体而言 里面有如下文件与文件夹:

1. `<PID>`: 所有进程的信息文件夹.
2. 当前访问procfs这个进程本身的软连接 指向`<PID>`中对应的部分.
3. 系统信息 比如cpu,mem,uptime,irq等
4. sysctl相关的对象
5. bus与driver
6. tty
7. acpi
8. 网络相关
9. 设备 磁盘与挂载点
10. 内核本身的信息

...
## 系统级接口
**内核** 与 **设备** 与**系统信息** 相关的procfs的内容.

### version
整个系统和内核的版本

```
Linux version 7.2.8-barrensea (portage@localhost) (x86_64-pc-linux-gnu-gcc (Gentoo 15.2.1_p20260214 p5) 15.2.1 20260214, GNU ld (Gentoo 2.45.1 p1) 2.45.1) #1 SMP PREEMPT_DYNAMIC Tue Sep 29 15:25:45 CST 2026
```

- Linux version 7.2.8-barrensea是内核
- (portage@localhost) 这是编译这个内核的用户. 比如我是用Gentoo的portage构建的
- 后面是gcc版本与ld链接器版本: `(x86_64-pc-linux-gnu-gcc (Gentoo 15.2.1_p20260214 p5) 15.2.1 20260214, GNU ld (Gentoo 2.45.1 p1) 2.45.1)`
- SMP: 内核开启了多处理器SMP
- PREEMPT_DYNAMIC: 抢占我开的动态选择. 具体是什么抢占可以看: `/sys/kernel/debug/sched/preempt`
- 最后是kernel的build时间
### uptime
