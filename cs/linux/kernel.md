# Linux内核

## 内核结构
![Linux Kernel Model](../../resource/LKM.svg)

在这个架构图中 Linux被拆解为5个部分: 用户接口(human interfaces) 系统(system) 进程管理(processing) 内存管理(memnory) 存储管理(storage) 网络管理(networking)

而这五个部分又被分为7个层级: 
- 用户空间接口(userspace interfaces)[这里面包含了系统调用和系统文件] 
- 虚拟(virtual)[主要表示内核中的逻辑抽象] 
- 桥接(briges)[连接转换不同的抽象层次] 
- 逻辑层(logical)
- 设备管理层(device control)
- 硬件接口(hardware interfaces)
- 设备层(electronics)
### human interfaces

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


## 内核参数(启动时)
当前内核的命令行参数`/proc/cmdline`

- init: 运行制定的二进制文件作为init进程
- initrd: 指定初始的ramdisk位置
- cryptdevice: 指定dm-crypt加密分区位置与设备映射器名称
- debug: 启动内核调试
- lsm: 设置linux安全模块的初始化顺序
- maxcpus: 将启用的最大处理器数量
- mem: 强制使用特定数量的内存
- netdev: 网络设备参数
- nomodeset: 禁用kernel mode setting
- acpi_os_name: 告诉 ACPI BIOS 操作系统的名称 格式：要伪装成 Windows 98：="Microsoft Windows"
- acpi_osi: 修改支持的操作系统接口字符串列表
  - "Microsoft Windows XP"
  - "Microsoft Windows 2000"
  - "Microsoft Windows 2000.1"
  - "Microsoft Windows ME: Millennium Edition"
  - "Microsoft WindowsME: Millennium Edition"
  - "Windows 2001"
  - "Windows 2006"
  - "Windows 2009"
  - "Windows 2012"
  - "Windows 2015"
  - "Windows 2020"

## 内核开发
Linux内核开发与其他项目不同. 采用邮件列表的补丁式贡献.

Linux内核分为很多子系统 比如Hwmon dma等 每个子系统都有不同的维护者.


### 子系统
下面列出Linux的子系统

#### rust-for-linux

Rust for Linux 是把 Rust 语言支持引入 Linux 内核的项目，目标是在内核中编写更安全的驱动和基础设施代码。Rust 代码仍然运行在内核态，不是用户态程序；它需要遵守内核的内存、并发、错误处理和构建规则。

| 子系统/组件 | 位于源码目录 | 介绍 |
|-------------|--------------|------|
| Rust support | `rust/` | Rust for Linux 的核心支持代码 |
| kernel crate | `rust/kernel/` | 提供给内核 Rust 代码使用的基础抽象，如设备、锁、内存分配等 |
| macros | `rust/macros/` | 过程宏，用于模块声明、绑定生成等 |
| bindings | `rust/bindings/` | 由 bindgen 从 C 头文件生成的 Rust FFI 绑定 |
| alloc | `rust/alloc/` | 内核环境下可用的 Rust allocation 支持 |
| uapi | `rust/uapi/` | 用户空间 ABI 相关绑定 |
| samples | `samples/rust/` | Rust 内核模块示例 |
| docs | `Documentation/rust/` | Rust for Linux 文档 |
| Kbuild | `scripts/`、`rust/Makefile` | Rust 编译、版本检查、bindgen、宏展开等构建逻辑 |

Rust for Linux 相关配置常见选项：

| 配置项 | 作用 |
|--------|------|
| `CONFIG_RUST` | 启用内核 Rust 支持 |
| `CONFIG_RUSTC_VERSION_TEXT` | 记录构建内核使用的 rustc 版本 |
| `CONFIG_SAMPLES_RUST` | 启用 Rust 示例模块 |

常用构建命令：

```shell
make LLVM=1 rustavailable
make LLVM=1 menuconfig
make LLVM=1
```

`rustavailable` 用于检查当前工具链是否满足内核 Rust 支持的要求。通常需要匹配内核文档中指定版本的 `rustc`、`bindgen`、`rust-src` 和 LLVM/Clang。

Rust 内核代码的主要特点：

- 不能使用 Rust 标准库 `std`，只能使用 `core`、`alloc` 和内核提供的抽象。
- 通过 `Result<T, Error>` 表示内核错误，错误值通常对应 Linux errno。
- 与 C 内核接口交互时需要 FFI，底层绑定来自 `rust/bindings/`。
- `unsafe` 仍然存在，但目标是把 unsafe 限制在小范围抽象内部。
- 当前主要适合新驱动和较独立的内核模块，核心子系统仍以 C 为主。

#### 驱动

| 子系统       | 位于源码目录                          | 介绍                         |
|--------------|---------------------------------------|------------------------------|
| uniwill      | `drivers/platform/x86/uniwill-wmi.c`  | uniwill模具的驱动            |
| platform/x86 | `drivers/platform/x86/`               | x86平台相关笔记本/主板驱动   |
| hwmon        | `drivers/hwmon/`                      | 硬件监控，如温度、电压、风扇 |
| input        | `drivers/input/`                      | 键盘、鼠标、触摸板等输入设备 |
| HID          | `drivers/hid/`                        | USB/Bluetooth HID设备        |
| LED          | `drivers/leds/`                       | LED设备与触发器              |
| USB          | `drivers/usb/`                        | USB主机、设备、控制器驱动    |
| PCI          | `drivers/pci/`                        | PCI/PCIe总线枚举与管理       |
| ACPI         | `drivers/acpi/`                       | ACPI表、事件、电源管理       |
| I2C          | `drivers/i2c/`                        | I2C总线与设备驱动            |
| SPI          | `drivers/spi/`                        | SPI总线与设备驱动            |
| TTY/serial   | `drivers/tty/`、`drivers/tty/serial/` | 终端、串口、控制台           |
| netdev       | `drivers/net/`                        | 网卡与网络设备驱动           |
| DRM/GPU      | `drivers/gpu/drm/`                    | 显示、显卡、KMS图形栈        |
| sound        | `sound/`                              | ALSA声卡与音频子系统         |
| block        | `drivers/block/`                      | 块设备驱动                   |
| NVMe         | `drivers/nvme/`                       | NVMe存储设备驱动             |
| MMC/SD       | `drivers/mmc/`                        | MMC、SD、eMMC设备            |
| power supply | `drivers/power/supply/`               | 电池、电源适配器、充电状态   |
| thermal      | `drivers/thermal/`                    | 温控区域、散热设备、降频策略 |

#### 内存

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| memory management | `mm/` | 页分配、虚拟内存、swap、内存回收、mmap等 |
| slab/slub | `mm/` | 内核对象缓存分配器 |
| page cache | `mm/`、`fs/` | 文件页缓存，连接文件系统和内存管理 |
| zswap/zsmalloc | `mm/` | 压缩swap缓存与压缩内存分配 |
| cma | `mm/` | 连续物理内存分配，常用于DMA |

#### 进程与调度

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| scheduler | `kernel/sched/` | 进程调度器，如CFS、RT、deadline |
| process management | `kernel/` | 进程创建、退出、信号等核心逻辑 |
| signal | `kernel/signal.c` | Unix信号处理 |
| fork/exec | `kernel/fork.c`、`fs/exec.c` | 进程复制与程序装载 |
| cgroup | `kernel/cgroup/` | 资源分组、限制和统计 |
| namespace | `kernel/` | pid、mount、user、net等命名空间 |

#### 文件系统与存储

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| VFS | `fs/` | 虚拟文件系统层，统一文件接口 |
| ext4 | `fs/ext4/` | ext4文件系统 |
| btrfs | `fs/btrfs/` | btrfs文件系统 |
| xfs | `fs/xfs/` | xfs文件系统 |
| procfs | `fs/proc/` | `/proc` 伪文件系统 |
| sysfs | `fs/sysfs/` | `/sys` 设备模型导出接口 |
| tmpfs | `mm/shmem.c` | 基于内存的临时文件系统 |
| block layer | `block/` | 块层，请求队列、I/O调度、bio |
| device mapper | `drivers/md/` | dm-crypt、LVM等映射设备框架 |
| md raid | `drivers/md/` | Linux软件RAID |

#### 网络

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| networking core | `net/core/` | 网络协议栈核心、skb、netdevice |
| IPv4 | `net/ipv4/` | IPv4协议实现 |
| IPv6 | `net/ipv6/` | IPv6协议实现 |
| netfilter | `net/netfilter/` | 防火墙、NAT、包过滤框架 |
| wireless | `net/wireless/` | cfg80211无线网络配置层 |
| mac80211 | `net/mac80211/` | 802.11无线协议栈 |
| bluetooth | `net/bluetooth/` | 蓝牙协议栈 |
| unix socket | `net/unix/` | Unix domain socket |
| eBPF | `kernel/bpf/`、`net/bpf/` | 内核可编程执行环境，常用于观测和网络 |

#### 安全

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| LSM | `security/` | Linux Security Module框架 |
| SELinux | `security/selinux/` | SELinux强制访问控制 |
| AppArmor | `security/apparmor/` | AppArmor路径型访问控制 |
| Smack | `security/smack/` | Smack访问控制模块 |
| keys | `security/keys/` | 内核密钥管理 |
| integrity | `security/integrity/` | IMA/EVM完整性度量与验证 |
| seccomp | `kernel/seccomp.c` | 系统调用过滤 |

#### 架构相关

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| arch | `arch/` | CPU架构相关代码总目录 |
| x86 | `arch/x86/` | x86架构启动、异常、中断、页表等 |
| arm64 | `arch/arm64/` | ARM64架构支持 |
| RISC-V | `arch/riscv/` | RISC-V架构支持 |
| boot | `arch/*/boot/` | 各架构启动代码与镜像生成 |

#### 中断、时间与同步

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| IRQ | `kernel/irq/` | 中断描述符、中断处理、irqchip接口 |
| timekeeping | `kernel/time/` | 时钟源、定时器、时间维护 |
| locking | `kernel/locking/` | mutex、spinlock、rwsem等锁实现 |
| RCU | `kernel/rcu/` | Read-Copy-Update同步机制 |
| workqueue | `kernel/workqueue.c` | 工作队列，异步执行内核任务 |

#### 观测与调试

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| tracing | `kernel/trace/` | ftrace、tracepoints、事件跟踪 |
| perf | `kernel/events/`、`tools/perf/` | 性能计数器与perf工具 |
| printk | `kernel/printk/` | 内核日志输出 |
| kprobes | `kernel/kprobes.c` | 动态探针机制 |
| debugfs | `fs/debugfs/` | 调试用伪文件系统 |
| KUnit | `lib/kunit/` | 内核单元测试框架 |

#### 虚拟化

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| KVM | `virt/kvm/`、`arch/*/kvm/` | Kernel-based Virtual Machine虚拟化 |
| virtio | `drivers/virtio/` | 半虚拟化设备框架 |
| vhost | `drivers/vhost/` | virtio后端加速 |
| Xen | `drivers/xen/`、`arch/x86/xen/` | Xen虚拟化支持 |

#### 库与通用基础设施

| 子系统 | 位于源码目录 | 介绍 |
|--------|--------------|------|
| lib | `lib/` | 通用算法、数据结构、校验、压缩等 |
| crypto | `crypto/` | 内核加密算法框架 |
| firmware | `firmware/` | 内核内置固件相关文件 |
| init | `init/` | 内核初始化与启动流程 |
| ipc | `ipc/` | System V IPC、POSIX消息队列等 |
| module | `kernel/module/` | 内核模块加载、卸载、符号解析 |

