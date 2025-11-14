# Python基础
有Rust基础的快速上手python

因为是快速上手 所以各种优化,细节都不会提及
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

其实就是Rust的HashSet 是一个哈希表 但是仍然可以放不同类型的元素

```python
a = {'a','b',1,True}
```

### Dict
字典

经典的KV表 就是Rust的HashMap 但是仍然可以存放不同类型的元素

```python
dict = {'name': 1, 'yes': False}
```
## 基本语法
### if_else
```python
	if a > b:
		func1()
	elif a< b:
		func2()
	else:
		func3()
```

### match_case
```python
match subject:
	case pattern_1:
		func1()
	case pattern_2:
		func2()
	case _:
		func3()
```

### while

```python
while a>b:
	func()
```

### for
这里python的for也是和rust一样对迭代器使用
```python
for i in Iterator:
	func()
	
```

#### range
类似rust的 `for i in 0..5`的语法

同样是前闭后开

```python
for i in range(0,5)
```

