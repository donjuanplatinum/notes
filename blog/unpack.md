# 解包
## Azurlane
### live2d
首先我们在qemu中下载碧蓝航线的live2d包

紧接着我们挂载qemu android的磁盘

```
sudo modprobe nbd
sudo qemu-nbd --connect=/dev/nbd0 /media/vdisk/android/android-x86-9.0
sudo mount /dev/nbd0p2 /mnt/
```

我们到路径`/mnt/你的qemu虚拟机目录/data/media/0/Android/data/com.bilibili.azurlane/files/AssetBundles/live2d`
