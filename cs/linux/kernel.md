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
### pselect


## 文件系统
`linux/fs`
### procfs
`linux/fs/proc`
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

