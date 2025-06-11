# Linux内核

## 编译内核

### 编译内核与模块
```shell
make all
```
### 安装内核与模块
```shell
  make INSTALL_MOD_STRIP=1 modules_install
  make install
```

### 生成initramfs
```shell
dracut --force --no-hostonly initramfs-6.12.27-barrensea.img 6.12.27-barrensea 
```

## 系统调用
`linux/arch/x86/entry/syscalls/syscall_64.tbl`
### pselect6
### inotify_init
`linux/fs/notify/inotify/inotify_user.c`
初始化一个inotify实例 返回一个文件描述符 默认为阻塞模式

系统调用注册
``` c
	SYSCALL_DEFINE0(inotify_init)
```


使用
```c
	int fd = inotify_init();
	if (fd == -1) {
		perror("init inotify failed");
		exit(EXIT_FAILURE);
	}
```
### inotify_init1
`linux/fs/notify/inotify/inotify_user.c`
初始化一个inotify实例 返回一个文件描述符 按照flags参数设置模式

系统调用注册
```c
	SYSCALL_DEFINE1(inotify_init1, int, flags)
```

使用
```c
	int fd = inotify_init1(IN_NONBLOCK | IN_CLOEXEC);
	if (fd == -1) {
		perror("inotify_init1 failed");
		exit(EXIT_FAILURE);
}
```
#### flags
`linux/include/uapi/linux/inotify.h`
```c
#define IN_CLOEXEC O_CLOEXEC
#define IN_NONBLOCK O_NONBLOCK
```
其中O_CLOEXEC与O_NONBLOCK为阻塞与非阻塞 定义于 `linux/include/uapi/asm-generic/fcntl.h`
### inotify_add_watch
`linux/fs/notify/inotify/inotify_user.c`
向inotify实例`fd`添加一个监控项 监视`pathname`对应文件目录事件 事件集由
```c
SYSCALL_DEFINE3(inotify_add_watch, int, fd, const char __user *, pathname,
		u32, mask)
```
### inotify_rm_watch
`linux/fs/notify/inotify/inotify_user.c`
```c
SYSCALL_DEFINE2(inotify_rm_watch, int, fd, __s32, wd)
```
## 文件系统
`linux/fs`
### procfs
`linux/fs/proc`
#### /proc/sys
- inotify
  - max_user_instances 限制每个用户创建的inotify实例([inotify_init](#inotify-init)系统调用的最大数量)
  - max_user_watches 限制每个用户可以监控的文件目录总数([inotify_add_watch](#inotify-add-watch)总数)
  - max_queued_events 限制单个inotify实例的事件队列最大长度
#### /proc/version
保存了内核版本和一些编译信息
``` shell
  cat /proc/version
  Linux version 6.6.13-gentoo-x86_64 (root@livecd) (x86_64-pc-linux-gnu-gcc (Gentoo 13.2.1_p20240113-r1 p12) 13.2.1 20240113, GNU ld (Gentoo 2.41 p4) 2.41.0) #1 SMP PREEMPT_DYNAMIC Sun Feb  4 13:22:48 CST 2024
```

#### /proc/cpuinfo
保存了与CPU相关的信息
#### /proc/config.gz
保存了内核的config文件的gzip
```shell
zcat /proc/config.gz
```

### Inotify
`linux/fs/notify/inotify`
inotify是Linux核心子系统之一，做为文件系统的附加功能，它可监控文件系统并将异动通知应用程序。本系统的出现取代了旧有Linux核心里，拥有类似功能之dnotify模块。

#### Inotify监控类型
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
```


#### Inotify系统调用
- [inotify_init][#inotify-init]

- [inotify_add_watch][#inotify-add-watch]

- [inotify_rm_watch][#inotify-rm-watch]
