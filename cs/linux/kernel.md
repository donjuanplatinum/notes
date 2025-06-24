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


