# Elisp
## Lisp语法
### 函数
```lisp
(defun square (x)
	(* x x)
)
```
## 语法
这里会列举出elisp的语法和形式
### 注释
| 语法                             | 形式                     |
|----------------------------------|--------------------------|
| 普通注释                         | ; text                   |
| 注释的特殊标记                   | ;####                    |
| 文档注释标记类似JAVADOC          | ;@param                  |
| 声明模式 告诉emacs使用何种主模式 | ;-*- mode: 模式名 -*-    |
| 声明编码                         | ; -*- coding: utf-8 -*- |
### 参数
| 语法     | 形式 |
|----------|------|
| 声明参数 | &optional arg1     |

声明参数的特殊语法
| 参数      | 行为                                                                     |
|-----------|--------------------------------------------------------------------------|
| &optional | 代表此参数可选 可以传入或不传入(只能使用一次 且置于必选参数后,&rest之前) |
| &rest     | 可变长度参数                                                             |
| &key      | 在elisp不可用,但可用cl-defun等效                                         |


## 注释
### 特殊标记
| 注释           | 作用     |
|----------------|----------|
| ;;;###autoload | 用于实现自动加载 类似于lazy_init 只在使用时加载 |

## 原始函数
这些函数就像rust的原始类型一般 基本由C语言实现 内置于emacs中
### integerp
这是一个C语言的内置函数
返回此函数是否为整数
```emacs-lisp
(integerp OBJECT)
```
### copy-marker
返回一个与 MARKER 指向相同位置的新标记。

这个标记会自动跟踪位置的更改

```emacs-lisp
(copy-marker &optional MARKER TYPE)
```

### point
返回现在光标位置
```emacs-lisp
(point)
```
### downcase
转换为小写
```emacs-lisp
(downcase OBJ)
```
### buffer-substring
返回start和end之间的字符串 
```emacs-lisp
(buffer-substring START END)
```
### looking-at
如果光标后的字符与正则表达式 REGEXP 匹配 则返回 t.
```emacs-lisp
(looking-at REGEXP &optional INHIBIT-MODIFY)
```
经常与match-end match-beginning match-data连用

### match-end
返回上一次搜索所匹配文本的结束位置
```emacs-lisp
(match-end SUBEXP)
```
SUBEXP是正则表达式的子表达式的序号

若SUBEXP=0 则返回整个正则表达式或整个字符串所匹配文本的结束位置
### assoc
查询关联列表
```emacs-lisp
(assoc KEY ALIST &optional TESTFN)
```
TESTFN是比较比较器 默认为equal
## 内置函数
这些函数也基本由c语言实现 内置于emacs中
### interactive
interactive用于定义函数如何与用户交互(例如获取参数的方式) 并使函数可用用M-x调用

interactive是内置函数 由c语言编写


``` emacs-lisp
(interactive &optional ARG-DESCRIPTOR &rest MODES)
```
其中`ARG-DESCRIPTOR`是可选的参数描述符

通常，interactive的参数是一个包含代码字母的字符串，后面可选择性地跟一个提示信息。（有些代码字母不需要通过输入 / 输出来获取参数，因此也不需要提示信息。）要向命令传递多个参数，可以将各个字符串连接起来，并用换行符分隔它们。


可用的代码字母有：
```
a -- 函数名：具有函数定义的符号。
b -- 已存在缓冲区的名称。
B -- 缓冲区名称，可能不存在。
c -- 字符（不使用输入法）。
C -- 命令名：具有交互式函数定义的符号。
d -- 作为数字的点位置值。不进行输入 / 输出。
D -- 目录名。
e -- 调用此命令的参数化事件（即列表形式的事件）。
如果多次使用，第 N 个 'e' 返回第 N 个参数化事件。
这会跳过整数或符号形式的事件。
f -- 已存在的文件名。
F -- 可能不存在的文件名。
G -- 可能不存在的文件名，默认为仅目录名。
i -- 忽略，即始终为 nil。不进行输入 / 输出。
k -- 键序列（如有需要，将最后一个事件转为小写以获取定义）。
K -- 要重新定义的键序列（不将最后一个事件转为小写）。
m -- 作为数字的标记值。不进行输入 / 输出。
M -- 任意字符串。继承当前输入法。
n -- 通过迷你缓冲区读取的数字。
N -- 数字前缀参数，如果没有，则类似代码 'n' 的行为。
p -- 转换为数字的前缀参数。不进行输入 / 输出。
P -- 原始形式的前缀参数。不进行输入 / 输出。
r -- 区域：作为两个数字参数的点和标记，从小到大排列。不进行输入 / 输出。
s -- 任意字符串。不继承当前输入法。
S -- 任意符号。
U -- 被之前的 k 或 K 参数丢弃的鼠标释放事件。
v -- 变量名：是 'custom-variable-p' 的符号。
x -- 读取但不求值的 Lisp 表达式。
X -- 读取并求值的 Lisp 表达式。
z -- 编码系统。
Z -- 编码系统，如果没有前缀参数则为 nil。
```

此外，如果字符串以'*' 开头，则当缓冲区为只读时会发出错误信号。

如果字符串以 '@' 开头，并且用于调用命令的键序列包含任何鼠标事件，则在运行命令之前会选中与这些事件中的第一个相关联的窗口。

如果字符串以 '^' 开头且'shift-select-mode' 为非 nil，Emacs 会首先调用函数 'handle-shift-selection'。

你可以同时使用 '@'、'' 和 '^'。它们会按照出现的顺序处理，在读取任何参数之前。

如果存在 MODES，它应该是一个或多个此命令适用的模式名称（符号）。这样，'M-x TAB' 就能在当前缓冲区的模式与列表不匹配时，将此命令从补全候选列表中排除。

基于此信息排除哪些命令由 'read-extended-command-predicate' 的值控制，详见其说明。

## 数据结构
### alist
关联列表 存储键值对
```emacs-lisp
(setq alist '((name . "Alice") (age . 30) (city . "Beijing")))
(assoc 'age alist)
```
## 常用
### play-sound
播放声音

SOUND 是一种形式为 (sound KEYWORD VALUE...) 的列表。

支持以下关键字：

:file FILE - 从文件 FILE 中读取声音数据。如果 FILE 不是绝对文件名，则会在 data-directory（数据目录）中搜索该文件。

:data DATA - 从字符串 DATA 中读取声音数据。

注意：必须且只能指定 :file 或 :data 中的一项。

:volume VOL - 将音量设置为 VOL。VOL 必须是 0..100 范围内的整数，或 0..1.0 范围内的浮点数。如果未指定，则不更改声音设备的音量设置。

:device DEVICE - 在设备 DEVICE 上播放声音。如果未指定，则使用与系统相关的默认设备名称。

注意：目前 Windows 系统不支持 :data 和 :device 关键字。
## 示例
计算 $1! + 2! + .. + n!$

这里使用类似霍纳规则的算法

$$
a_0 + a_0 * a_1 + a_0 * a_1 * a_2 = a_0(1 + a_1(1+ a_2))
$$

所以使用递归解决
```elisp
(defun f (x y)
  (if (= x y)
      y
    (* x (+ 1 (f (+ x 1) y)))))
```
