# GRUB
## 加入关机重启的grub选项
在`/etc/grub.d/40_custom`加入
```
menuentry "关机" {
halt
}
menuentry "重启" {
reboot
}
```
## Grub引导windows
找到windows的哪个EFI分区, 然后在grub命令行输入
```
chainloader /efi/Microsoft/Boot/bootmgfw.efi
boot
```
