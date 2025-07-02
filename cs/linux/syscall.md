# 系统调用
`linux/arch/x86/entry/syscalls/syscall_64.tbl`
## pselect6
## inotify_init
`linux/fs/notify/inotify/inotify_user.c`

初始化一个inotify实例 返回一个文件描述符 默认为阻塞模式

系统调用注册
``` c
	int inotify_init();
```

返回值 `int` 监控实例描述符

用户头文件 `sys/inotify.h`

示例
```c
	int fd = inotify_init();
	if (fd == -1) {
		perror("init inotify failed");
		exit(EXIT_FAILURE);
	}
```
## inotify_init1
`linux/fs/notify/inotify/inotify_user.c`

初始化一个inotify实例 返回一个文件描述符 按照flags参数设置模式

系统调用注册
```c
	int inotify_init1(int flags);
```

返回值 `int` 监控实例描述符

用户头文件 `sys/inotify.h`

示例
```c
	int fd = inotify_init1(IN_NONBLOCK | IN_CLOEXEC);
	if (fd == -1) {
		perror("inotify_init1 failed");
		exit(EXIT_FAILURE);
}
```
### flags
`linux/include/uapi/linux/inotify.h`
```c
#define IN_CLOEXEC O_CLOEXEC
#define IN_NONBLOCK O_NONBLOCK
```
其中O_CLOEXEC与O_NONBLOCK为阻塞与非阻塞 定义于 `linux/include/uapi/asm-generic/fcntl.h`
## inotify_add_watch
`linux/fs/notify/inotify/inotify_user.c`

向inotify实例`fd`添加一个监控项 监视`pathname`对应文件目录事件 事件集由mask指定 定义于`linux/include/uapi/linux/inotify.h`
```c
	int inotify_add_watch(int fd, const char *pathname, uint32_t mask);
```

返回值 `int` 成功时监控描述符wd 错误时errno

用户头文件 `sys/inotify.h`

示例
```c
	int fd = inotify_init(); // 初始化inotify实例
	int wd = inotify_add_watch(fd, argv[1], IN_ALL_EVENTS); // 向inotify实例添加监控项
	char buffer[1024];
	ssize_t len = read(fd, buffer, 1024);
	char *ptr = buffer;
	struct inotify_event *event = (struct inotify_event *)ptr; // 转换buffer为inotify_event类型
	printf("name %s mask %d",event->name,event->mask);	
```

## inotify_rm_watch
`linux/fs/notify/inotify/inotify_user.c`

删除inotify监控实例`wd` fd为inotify文件描述符

系统调用注册
```c
	int inotify_rm_watch(int fd, int wd);
```

用户头文件 `sys/inotify.h`

返回值 `int` 成功返回0
## chroot
`linux/fs/open.c`

用于更改进程的根目录 其中`path`为路径

系统调用注册
```c
	int chroot(const char *path);
```

用户头文件 `unistd.h`

示例
```c
	#include <unistd.h>
	if (chroot("/path") == -1) {
		return 1;
	}
```
## mkdir
`linux/fs/namei.c`
创建目录 其中 pathname为目录路径 mode为权限模式

系统调用原型
```c
#include <sys/stat.h>
#include <sys/types.h>
int mkdir (const char *pathname, mode_t mode);
```

返回值 `int` 成功0 失败-1 并设置errno

用户头文件`sys/stat.h`
示例
```c
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>

int main(){
	const char *dir_path = "./new";
	
	mode_t mode = 0755;
	if (mkdir(dir_path,mode) == 0 ) {
	printf("创建成功\n");
	} else {
		perror("mkdir 失败");
		return 1;
	}
	return 0;
}
```
