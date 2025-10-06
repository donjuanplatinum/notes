# 安卓虚拟机
使用qemu和blissos

```bash
#!/bin/bash
qemu-system-x86_64 \
-enable-kvm \
-M q35 \
-m 4096 -smp 4 -cpu host \
-bios /usr/share/edk2/OvmfX64/OVMF_CODE.fd \
-drive file=/media/vdisk/android/android-x86-9.0,if=virtio \
-usb \
-device virtio-tablet \
-device virtio-keyboard \
-device qemu-xhci,id=xhci \
-machine vmport=off \
-device virtio-vga-gl -display sdl,gl=on \
-audiodev pa,id=snd0 -device AC97,audiodev=snd0 \
-net nic,model=virtio-net-pci -net user,hostfwd=tcp::4444-:5555
```

访问qcow2

1. 加载nbd内核模块
```
sudo modprobe nbd
```

2. 查看镜像信息
```
qemu-img info disk.qcow2
```

3. 连接镜像
```
sudo qemu-nbd --connect=/dev/nbd0 disk.qcow2
```

现在可以使用`lsblk`查看qcow2的分区并挂载

4. 断开连接
```
sudo qemu-nbd --disconnect /dev/nbd0
```
