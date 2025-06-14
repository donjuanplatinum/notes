# lsof
List Open File 获取被进程打开文件的信息

## Args
```
  -a: 结果进行AND运算 而非OR
  +d 列出当前目录下(不包括子目录)
  +D 类似传统-R 遍历子目录
  +L 将链接计数打印在NLINK(+L指定的为开区间)
  -d 指定打开的文件描述符类型[见文件描述符类型]
  -g 组ID GID
  -N NFS文件
  -i 网络文件
  -R 列出PPID
  -x 跟踪文件系统链接
  -F 指定格式
  -l UID代替username
  -n 不域名解析
  -o 列出文件偏移offset
  -P 列出端口号而不是端口对应的默认服务
  -s 列出文件大小
  -r 间隔重复扫描
```
## 文件描述符表
```
（1）cwd：表示current work dirctory，即：应用程序的当前工作目录，这是该应用程序启动的目录，除非它本身对这个目录进行更改
（2）txt ：该类型的文件是程序代码，如应用程序二进制文件本身或共享库，如上列表中显示的 /sbin/init 程序
（3）lnn：library references (AIX);
（4）err：FD information error (see NAME column);
（5）jld：jail directory (FreeBSD);
（6）ltx：shared library text (code and data);
（7）mxx ：hex memory-mapped type number xx.
（8）m86：DOS Merge mapped file;
（9）mem：memory-mapped file;
（10）mmap：memory-mapped device;
（11）pd：parent directory;
（12）rtd：root directory;
（13）tr：kernel trace file (OpenBSD);
（14）v86  VP/ix mapped file;
（15）0：表示标准输入
（16）1：表示标准输出
（17）2：表示标准错误
一般在标准输出、标准错误、标准输入后还跟着文件状态模式：r、w、u等
（1）u：表示该文件被打开并处于读取/写入模式
（2）r：表示该文件被打开并处于只读模式
（3）w：表示该文件被打开并处于
（4）空格：表示该文件的状态模式为unknow，且没有锁定
（5）-：表示该文件的状态模式为unknow，且被锁定
同时在文件状态模式后面，还跟着相关的锁
（1）N：for a Solaris NFS lock of unknown type;
（2）r：for read lock on part of the file;
（3）R：for a read lock on the entire file;
（4）w：for a write lock on part of the file;（文件的部分写锁）
（5）W：for a write lock on the entire file;（整个文件的写锁）
（6）u：for a read and write lock of any length;
（7）U：for a lock of unknown type;
（8）x：for an SCO OpenServer Xenix lock on part      of the file;
（9）X：for an SCO OpenServer Xenix lock on the      entire file;
（10）space：if there is no lock.
```
## 文件类型表
```
（1）DIR：表示目录
（2）CHR：表示字符类型
（3）BLK：块设备类型
（4）UNIX： UNIX 域套接字
（5）FIFO：先进先出 (FIFO) 队列
（6）IPv4：网际协议 (IP) 套接字  
```

## 示例
### 循环扫描ssh的链接
```shell
	lsof -a -i -r -c ssh
```
### 扫描指定端口
```shell
	sudo lsof -a -i :443
```
### qbittorrent打开了什么文件
```shell
	lsof -c qbittorrent
```
