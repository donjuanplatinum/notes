# cpupower
监控调整CPU策略与频率

## 查看CPU信息

cpupower moniter 查看当前CPU频率等


## 修改CPU频率

cpupower frequency-set 

-u 设置最大频率
-d 设置最小频率
-c 应用于指定cpu编号

### Example
设置最大频率600M
```shell
sudo cpupower frequency-set -u 600000
```

