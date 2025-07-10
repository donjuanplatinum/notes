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
