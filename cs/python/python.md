# Python基础
有Rust基础的快速了解python

## 与Rust的一些区别
- Python在`显式`上是没有类型标注的 也不用打分号

- python的语句靠的是缩进来识别的

- Python是一行行跑的 假如你的错误在第10行 它不会通过检查报错 所以你可以跑到第9行

- Python的数组可以放不同类型的数据

## 基本类型
这里只挑出和Rust直觉不一样的

### List
在Python中叫列表 其实叫数组 但是它和Rust的元组一样可以放不同类型的数据

```python
a = ['1','2',3,True,{"a":1}]
```

### Tuple
元组 

与List区别在于tuple的元素不可变  所以比List快点 (所以其实List是mut的多类型的Vec,而tuple是unmut的多类型的array)

```python
tuple = ('abcd',123,True)
```

### Set
集合
