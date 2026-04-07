# Systemd

## journalctl
日志分析工具

- `--disk-usage`: 日志的磁盘占用
- `-f`: 实时滚动查看 类似 `tail -f`
- `-b`: 查看启动后所有日志
- `PATH`: PATH的服务的日志
- `--since "TIME"`: 从什么时间开始 TIME支持很多种写法 比如`10 min ago`,`yyyy-mm-dd hh:mm:ss`
- `--until "TIME"`: 到什么时候
- `-u`: 用户
- `-x`: 添加描述
- `-p`: 过滤日志优先级 `0: emerge, 1: alert, 2: crit,3: err,4: warning,5: notice,6: info, 7: debug`

## systemd-run
创建临时服务的工具 也能用来限制资源的创建进程
