# Matplotlib
科学画图 与Numpy库强关联

## matplotlib.pyplot
类似MATLAB的绘图接口 每个pyplot函数会对图形做更改

### plot
```python
matplotlib.pyplot.plot(*args, scalex=True, scaley=True, data=None, **kwargs)[source]
```

其中
- *args
表示动态的输入格式 例如 `plot(y)` `plot(x,y)` `plot(x1,y1,x2,y2,...)`
- scalex
示例
```
plt.plot([1,2,3])
plt.show()
plt.plot([1,2,3],[2,3,4])
plt.show()
```
