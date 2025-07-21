# 虚拟化

## virsh
列出虚拟机 virsh list
关机 virsh shutdown
强制关机 virsh destory

## qemu-img
创建虚拟磁盘 qemu-img create -f qcow2 PATH SIZE
调整大小 qemu-img resize PATH SIZE
## virt-install
virt-install --name NAME --disk DISKPATH --cdrom ISO --memory MEMORYSIZE

