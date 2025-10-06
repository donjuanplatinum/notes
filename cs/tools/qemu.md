# QEMU
最高效的模拟器之一

## 包集合
- ivshmem-client/server: guest和host共享内存的应用程序 
- qemu-ga: 不利于网络实现guest和gost之间交互的程序
- qemu-io: 执行qemu I/O操作的命令行工具
- qemu-system-ARCH: QEMU核心程序 用于虚拟机创建 根据架构分为不同的ARCH
- qemu-img: 创建虚拟机镜像的工具
- qemu-nbd: 挂载工具

## qemu-img
创建QCOW2虚拟磁盘
```shell
qemu-img create -f qcow2 android.qcow2 20G
```

## qemu-system-ARCH
- enable-kvm: 打开kvm支持
- m: 指定内存大小
- s: gdb启用
- S: 启动时暂停 等待GDB连接
- M: 指定machine help列出所支持的machine
- smp: CPU核数
- kernel: linux kernel路径
- append: linux kernel的bootargs
- console: 串口 设备名必须与machine的串口一致
- initrd: initrd
- cdrom: 指定iso
- drive file= ,format=: 指定磁盘
- bios: 指定BIOS
- boot: d: 从cdrom启动 c: 从硬盘启动 n: 网络启动 order: 指定多设备启动顺序 menu=on/off 启动菜单
- cpu: 指定模拟cpu help列出所支持
- usb: 打开usb
- device: 添加设备 help列出所有
