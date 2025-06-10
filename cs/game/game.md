# 游戏环境
## Wine
### 创建新环境
```shell
  export WINEPREFIX=~/wine/software winecfg
  WINEARCH=win32 WINEPREFIX=~/.wine32 winecfg # 32位
  WINEPREFIX=... LC_ALL=zh_CN.UTF-8 winecfg # 中文
```

### 注意事项
一般最好把dxvk和vkd3d装上 除了特殊游戏
其次Fonts可以从windows复制
gstream相关库最好都装好
## 游戏
### 小兵步枪
在rwr_config.exe中修改显示为 ~OpenGL~ 然后关闭全屏  否则会导致游戏显示异常

### 美少女万华镜-雪女
设置中选择全屏

打开Win32api模式
### 上古卷轴5
#### 闪烁问题
安装dxvk
#### 声音问题
安装xact

### 生化危机
最好不开dxvk

### Elden Ring
艾尔登法环需要EAC 及 vkd3d

EAC可以通过Lutris的EAC或者在 `glibc` 的编译选项里打开hash-sysv-compat

### Minecraft
服务器jvm启动参数
```shell
  -Xms4G
  -Xmx8G
  -XX:+UseG1GC
  -XX:+ParallelRefProcEnabled
  -XX:MaxGCPauseMillis=200
  -XX:+UnlockExperimentalVMOptions
  -XX:+DisableExplicitGC
  -XX:+AlwaysPreTouch
  -XX:G1NewSizePercent=30
  -XX:G1MaxNewSizePercent=40
  -XX:G1HeapRegionSize=8M
  -XX:G1ReservePercent=20
  -XX:G1HeapWastePercent=5
  -XX:G1MixedGCCountTarget=4
  -XX:InitiatingHeapOccupancyPercent=15
  -XX:G1MixedGCLiveThresholdPercent=90
  -XX:G1RSetUpdatingPauseTimePercent=5
  -XX:SurvivorRatio=32
  -XX:+PerfDisableSharedMem
```
