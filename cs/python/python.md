# Python基础
有Rust基础的快速上手python

因为是快速上手 所以各种优化,细节都不会提及

本文适用于有Rust或者ELisp基础的 能快速上手Python
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

### 推导式
这个是python独特的语法 逻辑有点类似rust闭包来处理迭代器 但是语法不一样

我会以Rust的等价形式来方便理解

#### 列表推导式
```python
>>>names = ['donjuan','donplat','Mushoku','Saluzo_']
>>>new_names = [name.upper() for name in names if len(name) > 3]
>>>print(new_names)
['DONJUAN', 'DONPLAT', 'MUSHOKU', 'SALUZO_']
```

相当于rust的
```rust
let names: [&str;3] = ["donjuan","mushoku","saluzo_"];
let new_names: Vec<String>  = names.into_iter().map(|str| str.to_uppercase()).collect();
```

#### 字典推导式
```python
{k:v for v in collection if cond}
```

```python
>>>list = ['mushoku','zgjsdis','qwe','donjuanplatinum']
>>>newdict = {key:len(key) for key in list}
>>>print(newdict)
{'mushoku': 7, 'zjgsdis': 7, 'qwe': 3, 'donjuanplatinum': 15}
```

这等价于rust的
```rust
use std::collections::HashMap;
let list: [&str;4] = ["mushoku","zgjsdis","qwe","donjuanplatinum"];
let new_dict: HashMap<&str,usize> = list.iter().map(|&name| (name,name.len())).collect();

```
#### 集合推导式/元组推导式
没什么区别
### 迭代器
和rust差不多 没什么区别

创建迭代器
```python
list = [1,2,3,4]
iter(list)
```
### with
有点像rust的生命周期 在with结束后自动drop

```python
with open('example.txt','r') as file:
	content = file.read()
	print(content)
# 在这里file会自动释放	
```
with语句结束时 会调用__exit()__ 来释放对象

### 函数
在python里 函数的参数和Rust非常的不一样. 它的参数列表长度是可变的.

在rust里 函数的参数是多少 调用时就得写多少
 
```python
def func(*args,a=False,b,**kwargs):
	print(args)
	print(b)
	if a:
	    for name,age in kwargs.items():
                print(f"name: {name},age: {age}")
func("o","k",a=True,b=123,name="donplat",age="100")
```

在EmacsLisp中 有类似的语法 我们可以理解为Elisp

这里的参数:
- *args: 这是一个特殊的参数 代表`可变长度`的参数, python会收集为元组tuple. 在Elisp中 相当于&rest
- a=False: 这代表a默认为False 如果不显式指定的话 在elisp中 相当于&optional
- b: 这是必须传入的参数 
- **kwargs: 这个是一个可变长的键值对 在elisp中 相当于&key



### 闭包
在python和cpp中 闭包叫lamba表达式 

```python
f = lambda a : a +10
print(f(5))
```

等价于rust的
```rust
let a = |a| a+5;
```

### 装饰器
其实就是rust的宏 数学里的泛函

装饰器是一种函数 接收一个函数为参数 返回一个新的函数 (其实就是泛函)

其实这就类似rust actix框架的#[get("/")] 或者tokio的#[tokio::main]
```python
def http_wrap(status_code=200, content_type="text/plain"):
    def decorator(func):
        def wrapper(*args, **kwargs):
            body = func(*args, **kwargs)
            head = (
                f"HTTP/1.1 {status_code} OK\n"
                f"Content-Type: {content_type}\n"
                f"Content-Length: {len(body.encode('utf-8'))}\n"
                f"\n"
            )
            return head + body
        return wrapper
    return decorator


@http_wrap(status_code=404)
def hello():
    return "Hello! I'm ok"


print(hello())
```

这里实现了一个HTTP封装器 其中 decortator接收了作用的函数hello 

wrapper对hello函数做了变换 给hello函数的返回值加入了HTTP头

### 类装饰器
和装饰器一样 只不过变换的是类Class

因为是快速入门 故不做过多介绍



### 面向对象
这个和Rust大不一样 Rust的面向对象行为由类型系统和Trait

#### 类
```python
class MyClass:
	i = 1234
	def f(self):
		return 'hello world'
```

在rust中 类型的成员定义和方法定义是分开的 

成员定义在`struct`,`union`等 而方法定义在`impl`中

python的成员和函数是放在一起定义的

python的变量也分私有和公共 类似rust的pub

python变量加两个__代表私有
```python
class Vec:
	__data = [] # 私有
	len
	def __init__(self):
            self.__data=[]
            self.len = 0
	def print(self):
		print self.__data
```

#### 类的特殊函数
1. 构造函数__init__()

rust是没有自动调用的构造函数的

python有一个叫__init__()的特殊方法 是实例化时自动调用的函数

```python
class Vec:
    data = []
    def __init__(self):
        self.data = []
        print(self.data)

x = Vec()
```

2. 析构函数__del__()

类似rust的drop

3. 还有很多不介绍了 可以理解为Trait 比如加减乘除的实现等
### 命名空间
这个和rust差不多 只不过python用`.` rust用`::`

## 结语
到这里为止 你就掌握了python的基础 至于其他的库 可以翻阅文档查看
