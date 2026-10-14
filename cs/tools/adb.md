# adb
调试android设备的工具

在我们gentoo里叫:

```
acct-group/android
dev-util/android-tools
```



- wifi连接

```shell
adb pair 192.168.101.237:37073
```

> **注意,配对的端口与连接的端口不一样**


配对完后使用`connect`连接

```
adb connect 192.168.101.237:37993
```
## shell
连接完成后

进入shell
```
adb shell
```


### 包管理
```shell
pm list 
```
