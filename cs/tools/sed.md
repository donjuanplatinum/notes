# Sed
## 动作

- a: 新增字符串到下一行
- c: 使用字符串取代
- d: 删除
- i: 插入字符串到上一行
- p: 打印
- s: 替换字符
- {}: 执行操作

在第四行的下一行加入字符串
```shell
sed -i '4 a nihao\n' testfile
```

删除2-5行
```shell
sed -i '2,5d'
```

删除3-最后一行
```shell
sed -i '3,d'
```

找到[XWayland]开始的行 并在下一行替换Scale的值
```shell
sed -i '/^\[XWayland\]$/{n;s/Scale=.*/Scale=1.75/}' ~/home/.config/kwinrc
```
