# Shell
## 每秒将占用最大的进程打印
```shell
for ((;;));do ps aux --sort=-%mem;sleep 1;done
```


## Linux桌面创建通知
```
notify-send "标题" "通知内容"
```
## 进程是否存在
``` bash
  while true ; do if ! ps  -p 10605; then notify-send 'ok';play -n synth 10 sine 1000;break ;fi ;sleep 5;done
```
## 发出声音警报
``` shell
play -n synth 1 sine 10000
```

## 系统备份
``` shell
  sudo tar -cjpvf gentoobackup.tar.gz  --exclude=/run --exclude=/mnt --exclude=/proc/ --exclude=/sys --exclude=/dev --exclude=/var/cache --exclude=/var/tmp --exclude=/tmp --exclude=/home --exclude=/root /
```




