# GDB调试器
## Cli
### 运行
gdb Program [core dump] # 启动gdb
gdb --args program args... # 传入程序的args
adb --pid PID # gdb附加到进程

## 交互式
- 文件
set args 指定args
- 进程
run/r 运行程序
kill 杀掉进程
list/l 列出源代码
frame/f 现在位置

- 断点
break <where> 下断点
delete <breakpoint#> 删断点
clear 删所有断点
enable <breakpoint#> 启用断点
disable <breakpoint#> 禁用断点
info <breakpoint> 查看断点信息


- 观察点
watch <where> 下观察点
delete/enable/disable <watchpoint#> 类似


- <where>的类型
函数名
行号
文件:行号

- Conditions
break/watch <where> if <condition>

- 变量
print/p [val] 打印变量
info local 查看本地变量
