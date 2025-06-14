# Strace
Strace可以诊断 调试Linux用户空间
检测进程与内核的交互 系统调用 信号 状态变更等

## Args
```
| -c          | 统计                  |
| -f          | 追踪fork子进程         |
| -ff         | 将为每个子进程          |
| -F          | 追踪vfork调用          |
| -i          | 输出系统调用入口指针    |
| -q          |                      |
| -r          | 输出相对时间           |
| -t -tt -ttt | 输出的每一行加入时间    |
| -T          | 显示系统调用所需时间    |
| -v          | 输出所有调用           |
| -x          | 十六进制输出非标准字符串 |
| -xx         | 十六禁止输出所有字符串   |
| -e expr     | 指定表达式来控制如何追踪 |
| -p pid      | 追踪指定的进程          |
| -u user     | 以user身份执行         |
```
### -e expr
```
| trace   | 指定追踪的系统调用     |
| abbrev  | 输出系统调用的结果集合  |
| verbose |                     |
| raw     | 十六进制显示          |
| signal  | 指定追踪的信号 默认all |
```
### trace集合
```
| file    | 与文件相关的系统调用    |
| process | 与进程相关的系统调用    |
| network | 与网络相关的系统调用    |
| signal  | 与信号相关的系统调用    |
| ipc     | 与进程通讯相关的系统调用 |
```
## Examples
不追踪sigio信号
```shell
  strace -e signal=!SIGIO
```

通用用法
``` shell
strace -o output -T -tt -e trace=file -p pid
```
