# 串口
Linux的串口通信(Serial)

都是遵循TTY子系统的框架

主要分为以下三类

- UART: 最原始纯粹的串口 代表性的有 `ttyAMA0`,`ttyS0`


直接由SoC内部的UART控制器驱动 寄存器**简单**.

- USB-Serial: 物理上是USB 代表设备有 `ttyUSB0`, `ttyCH341`..


- USB Gadget Serial(从机): `ttyGS0`等 没有物理的串口控制器 而是使用USB协议栈作为底层 通过内核进行翻译.

也就是说 在`ttyGS0`里写入字符 实际上触发的是USB传输

当主板为Host时 相当于插了一个外接的USB转串口 那就是USB-Serial

当主板自己作为外设时(相当于插了一个USB到开发板 让开发板作为串口) 则为USB Gadget Serial

