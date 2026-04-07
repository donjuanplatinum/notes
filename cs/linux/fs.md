# 文件系统
`linux/fs`
## procfs
`linux/fs/proc`
### /proc/sys
- inotify
  - max_user_instances 限制每个用户创建的inotify实例([inotify_init](#inotify-init)系统调用的最大数量)
  - max_user_watches 限制每个用户可以监控的文件目录总数([inotify_add_watch](#inotify-add-watch)总数)
  - max_queued_events 限制单个inotify实例的事件队列最大长度
### /proc/version
保存了内核版本和一些编译信息
``` shell
  cat /proc/version
  Linux version 6.6.13-gentoo-x86_64 (root@livecd) (x86_64-pc-linux-gnu-gcc (Gentoo 13.2.1_p20240113-r1 p12) 13.2.1 20240113, GNU ld (Gentoo 2.41 p4) 2.41.0) #1 SMP PREEMPT_DYNAMIC Sun Feb  4 13:22:48 CST 2024
```

### /proc/cpuinfo
保存了与CPU相关的信息
### /proc/config.gz
保存了内核的config文件的gzip
```shell
zcat /proc/config.gz
```
### /proc/kcore
`fs/proc/kcore.c`
动态的内核文件 包含了系统中内核运行的所有数据
### /proc/irq
IRQ中断请求的详细信息

- default_smp_affinity 指明了适用于所有非激活IRQ的默认亲和性掩码 一旦IRQ被 分配/激活，它的亲和位掩码将被设置为默认掩码。然后可以如上所述改变它。默认掩码是0xffffffff

- IRQS(irq编号)
	- smp_affinity 指定当前IRQ关联的CPU编号的掩码
	- smp_affinity_list 指定当前IRQ关联的CPU编号的列表


限制由CPU1来处理wifi 我的wifi的irq编号94
```
cd /proc/irq/94
echo 1 > smp_affinity_list
cat /proc/interrupts |grep -i 'CPU\|94:'
```
### /proc/cmdline
当前内核的启动参数
### /proc/PID/maps
进程的内存布局

通过分析这个文件，我们可以了解进程使用内存的全貌，包括代码段、数据段、堆、栈、共享库、动态分配的内存等。

示例
```
00400000-0040b000 r-xp 00000000 08:01 1234567  /usr/bin/ls
```

| 字段         | 含义                                                                                                                                                             |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 004...-004.. | 内存地址范围                                                                                                                                                     |
| r-xp         | 权限标志位 分别为读,写,执行,是否为私有(p)映射                                                                                                                    |
| 000000       | 偏移量 映射文件在磁盘上的偏移量（十六进制）若为匿名映射（如堆、栈），则为 0。                                                                                    |
| 08:01        | 设备号：映射文件所在的设备标识符（主设备号：次设备号）。匿名映射通常为 00:00 或 fe:00（tmpfs）。                                                                 |
| 123456       | inode号: 映射文件的inode编号 匿名映射为0                                                                                                                         |
| /usr/bin/ls  | 映射文件的路径或特殊区域 可能值: 路径, [heap]: 堆,[stack]: 栈, [anon]:匿名映射,[vdso]: 虚拟动态共享对象,[vvar]:内核变量的用户空间映射,[vsyscall]: 旧系统调用映射 |
### /proc/PID/smaps
更详细的内存布局
| 字段            | 含义                                                                                |
|-----------------|-------------------------------------------------------------------------------------|
| Size            | 虚拟地址大小                                                                        |
| KernelPageSize  | 内核页大小:系统内核使用的内存                                                       |
| MMUPageSize     | MMU页大小                                                                           |
| Rss             | 驻留内存: 实际占用的物理内存                                                          |
| Pss             | 比例共享内存: 该虚拟内存区域平摊计算后使用的物理内存大小.  Pss 比 Rss 更能准确反映进程的 “实际内存消耗”                        |
| Pss_Dirty       | 脏页比例共享内存: Pss 中被修改过的内存（脏页） 即该区域所有物理内存都已被写入过数据 |
| Shared_Clean    | 共享干净页: 被多个进程共享且未修改的物理内存                                        |
| Shared_Dirty    | 共享脏页: 被多个进程共享且已修改的物理内存                                          |
| Private_Clean   | 私有干净页: 仅当前内存使用的未被修改的内存                                          |
| Private_Dirty   | 私有脏页: 仅当前进程使用且已修改的内存                                              |
| Referenced      | 已访问内存(活跃内存): 内核不会优先同步到磁盘                                        |
| Anonymous       | 匿名内存: 该区域无磁盘文件(非文件映射)                                              |
| KSM             | 未使用KSM技术合并的内存页(该区域内存无重并)                                         |
| LazyFree        | 延迟释放内存                                                                        |
| AnonHugePages   | 匿名大页                                                                            |
| ShmemPmdMapped  | 共享内存大页映射 共享内存通过PMD映射的大页                                          |
| FilePmdMapped   | 文件大页映射                                                                        |
| Shared_Hugetlb  | 共享大页                                                                            |
| Private_Hugetlb | 私有大页                                                                            |
| Swap            | 非mmap内存由于                                                                            |
| SwapPss         | 交换页比例共享内存                                                                  |
| Locked          | 锁定内存: 被mlock等调用锁定                                                                            |
### /proc/mounts
已挂载文件系统表
### /proc/interrupts
系统中断统计信息

示例格式:
```
            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       CPU8       CPU9       CPU10      CPU11      CPU12      CPU13      CPU14      CPU15      CPU16      CPU17      CPU18      CPU19      
   0:         44          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 IR-IO-APIC    2-edge      timer
   1:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0       3252          0          0 IR-IO-APIC    1-edge      i8042
   3:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 IR-IO-APIC    3-edge      AMDI0010:00
   4:          0          0          0     187823          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 IR-IO-APIC    4-edge      AMDI0010:01
   7:          0          0          0          0          0       5771          0          0          0          0          0          0          0          0          0          0          0          0          0          0 IR-IO-APIC    7-fasteoi   pinctrl_amd
   8:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 IR-IO-APIC    8-edge      rtc0
   9:          0        910          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 IR-IO-APIC    9-fasteoi   acpi
  27:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 PCI-MSI-0000:00:00.2    0-edge      AMD-Vi
  28:          0          0          0          0          0          1          0          0          0          0          0          0          0          0          0          0          0          0          0          0 amd_gpio    0  ACPI:Event
  29:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 amd_gpio    7  ACPI:Event
  30:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0 amd_gpio   61  ACPI:Event

```

其中 第一列显示的就是irq的编号，最后一列显示的就是irq的来源，倒数第二列显示的就是irq的触发方式，倒数第三列显示的就是irq的名称

## sysfs
### /sys/devices/system/cpu/CPUID/cpufreq
内核的cpu频率调节接口

- scaling_cur_frequencies: 当前cpu频率
- scaling_min_freq: 当前频率下限
- scaling_max_freq: 上限
- scaling_governor: 当前调节器
- scaling_drvier: 当前驱动
- scaling_available_governors: 可用调节器
## Inotify
`linux/fs/notify/inotify`
inotify是Linux核心子系统之一，做为文件系统的附加功能，它可监控文件系统并将异动通知应用程序。本系统的出现取代了旧有Linux核心里，拥有类似功能之dnotify模块。

### Inotify事件类型
`linux/include/uapi/linux/inotify.h`
```
/* 以下是合法的、已实现的事件，用户空间可以监听这些事件 */
#define IN_ACCESS		0x00000001	/* 文件被访问 */
#define IN_MODIFY		0x00000002	/* 文件被修改 */
#define IN_ATTRIB		0x00000004	/* 元数据变更 */
#define IN_CLOSE_WRITE		0x00000008	/* 可写文件被关闭 */
#define IN_CLOSE_NOWRITE	0x00000010	/* 不可写文件被关闭 */
#define IN_OPEN			0x00000020	/* 文件被打开 */
#define IN_MOVED_FROM		0x00000040	/* 文件从X移动 */
#define IN_MOVED_TO		0x00000080	/* 文件移动到Y */
#define IN_CREATE		0x00000100	/* 子文件被创建 */
#define IN_DELETE		0x00000200	/* 子文件被删除 */
#define IN_DELETE_SELF		0x00000400	/* 自身被删除 */
#define IN_MOVE_SELF		0x00000800	/* 自身被移动 */

/* 以下是合法事件，它们会按需发送给所有监听器 */
#define IN_UNMOUNT		0x00002000	/* 底层文件系统被卸载 */
#define IN_Q_OVERFLOW		0x00004000	/* 事件队列溢出 */
#define IN_IGNORED		0x00008000	/* 文件被忽略 */

/* 辅助事件 */
#define IN_CLOSE		(IN_CLOSE_WRITE | IN_CLOSE_NOWRITE) /* 关闭事件 */
#define IN_MOVE			(IN_MOVED_FROM | IN_MOVED_TO) /* 移动事件 */

/* 特殊标志 */
#define IN_ONLYDIR		0x01000000	/* 仅当路径是目录时监听 */
#define IN_DONT_FOLLOW		0x02000000	/* 不追踪符号链接 */
#define IN_EXCL_UNLINK		0x04000000	/* 排除已解除链接对象的事件 */
#define IN_MASK_CREATE		0x10000000	/* 仅创建监听 */
#define IN_MASK_ADD		0x20000000	/* 添加到已存在监听的掩码 */
#define IN_ISDIR		0x40000000	/* 事件发生在目录上 */
#define IN_ONESHOT		0x80000000	/* 仅发送事件一次 */

/* 所有事件集合 */
#define IN_ALL_EVENTS	(IN_ACCESS | IN_MODIFY | IN_ATTRIB | IN_CLOSE_WRITE | \
			 IN_CLOSE_NOWRITE | IN_OPEN | IN_MOVED_FROM | \
			 IN_MOVED_TO | IN_DELETE | IN_CREATE | IN_DELETE_SELF | \
			 IN_MOVE_SELF)

```



### Inotify系统调用
- [inotify_init][#inotify-init]
Q
- [inotify_add_watch][#inotify-add-watch]

- [inotify_rm_watch][#inotify-rm-watch]
## tmpfs
基于内存的文件系统
### /dev/shm
默认为内存大小的一半 驻留在内存中 读写异常快

修改大小
```
mount -o remount,size=32G tmpfs /dev/shm
```
