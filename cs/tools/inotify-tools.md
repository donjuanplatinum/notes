# Inotify-tools
inotify事件监听 监控 统计工具, 能监视文件的inotify事件

inotify-tools包含两个工具

- inotifywait: 滚动输出 类似strace
- inotifywatch: 统计 类似perf

## inotifywait
监控事件:
```shell
inotifywait -m -e [events] -r path
```

-m 持续监控 (默认只监控一次)
-e 指定事件集
-r 子目录递归


## 事件
事件定义于内核
`linux/include/uapi/linux/inotify.h`
```shell
Events:
	access		file or directory contents were read
	modify		file or directory contents were written
	attrib		file or directory attributes changed
	close_write	file or directory closed, after being opened in
	           	writable mode
	close_nowrite	file or directory closed, after being opened in
	           	read-only mode
	close		file or directory closed, regardless of read/write mode
	open		file or directory opened
	moved_to	file or directory moved to watched directory
	moved_from	file or directory moved from watched directory
	move		file or directory moved to or from watched directory
	move_self		A watched file or directory was moved.
	create		file or directory created within watched directory
	delete		file or directory deleted within watched directory
	delete_self	file or directory was deleted
	unmount		file system containing file or directory unmounted
	```
## 使用事例
我需要找到kde的屏幕缩放的设置放在$HOME/.config的哪个文件 

我们先inotifywait 创建inotify监控实例 更改文件events为modify

```shell
inotifywait -r -m -e modify ~/.config
```

然后在kde的设置中改一次设置 得到输出
```shell
Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.
./ MODIFY kwinoutputconfig.json
./ MODIFY kwinrc.lock
./ MODIFY #16959842
./xsettingsd/ MODIFY xsettingsd.conf
./xsettingsd/ MODIFY xsettingsd.conf
./xsettingsd/ MODIFY xsettingsd.conf
./xsettingsd/ MODIFY xsettingsd.conf
./dconf/ MODIFY user.6EEMA3
./dconf/ MODIFY user.6EEMA3
./ MODIFY #16959815
./ MODIFY #16959815
./ MODIFY #16959844
./ MODIFY #16959844
./gtk-3.0/ MODIFY settings.ini.lock
./gtk-3.0/ MODIFY #235041463
./gtk-4.0/ MODIFY settings.ini.lock
./gtk-4.0/ MODIFY #302145488
./ MODIFY Trolltech.conf.lock
./ MODIFY #16961920
```

我们通过调查每个文件的内容定位到了kwinrc文件
