# Elisp
## GNU Emacs原生库
### C库
| 库      | 作用                  |   |               |
|---------|-----------------------|---|---------------|
| editfns | 文本编辑内建函数      |   | src/editfns.c |
| eval    | 执行代码              |   | src/eval.c    |
| search  | 搜索逻辑              |   | src/search.c  |
| fns     | 通用函数              |   | src/fn.c      |
| alloc   | 堆分配                |   | src/alloc.c   |
| data    | 数据类型的操作        |   | src/data.c    |
| syntax  | 语法表解析            |   | src/syntax.c  |
| buffer  | 缓冲区操作            |   | src/buffer.c  |
| process | 进程相关              |   | src/process.h |
| fileio  | 文件接口              |   | src/fileio.c  |
| insdel  | buffer的插入 删除操作 |   | src/insdel.c  |
### elisp库
| 库      | 作用                     |                             |                           |
|---------|--------------------------|-----------------------------|---------------------------|
| subr    | 最底层最重要的公共函数库 | 相当于std                   | lisp/subr.el              |
| subr-x  | subr的扩展               |                             | lisp/emacs-lisp/subr-x.el |
| seq     | 序列的接口               | 类似于rust的slice vec array |                           |
| map     | 各种map 如 hash-table等  |                             |                           |
| cl-lib  | common-lisp的拓展        |                             |                           |
| pcase   | 模式匹配                 | rust的match                 |                           |
| nadvice | advice系统 动态修改函数  |                             |                           |
| eieio   | OO系统                   |                             |                           |
| json    | json解析                 |                             |                           |
| url     | http解析                 |                             |                           |
| project | 官方project管理          |                             |                           |
| xref    | 统一跳转接口             | eglot什么的几乎都用这个     |                           |
| imenu   | 代码索引                 |                             |                           |
| compile |                          |                             |                           |
| flymake | 实时诊断                 |                             |                           |
| treesit | tree-sitter官方接口      |                             |                           |
| syntax  | 语法分析                 |                             | lisp/emacs-lisp/syntax.el |
| calc    | calc子系统的接口         | 数值计算之类的              | lisp/calc                 |
## 库接口
### calc系列
#### calc-do-quick-calc
在任意buffer中进行计算

`(defun calc-do-quick-calc (&optional insert)`
#### calc-binary-op
取出calc栈顶的两个操作数 然后得到一个结果 压回栈. 这是逆波兰的基础操作.

`(calc-binary-op NAME FUNC ARG &optional IDENT UNARY FUNC2)`

- `NAME`: 运算符的名字
- `FUNC`: 二元运算符实际调用的函数
- `ARG`: 当前command的prefix arg
- `IDENT`: 可选的用于处理空栈,缺少操作数时候的操作
- `UNHARY`: 是否/如何支持一元形式
- `FUNC2`: 二元运算的另一个实现函数

示例:

`(calc-binary-op "+" 'calcFunc-add arg 0 nil '+)`
#### math-numberp
判断是不是calc的数字类型

`(math-numberp A)`
#### math-reject-arg
在calc计算器中拒绝参数

`(math-reject-arg &optional A P OPTION)`

- A: 出问题的参数
- P: 要求满足的predicate
- option: 额外错误原因
#### math-with-extra-prec
临时拓展精度 执行body.

`(math-with-extra-prec DELTA &rest BODY)`

- `DELTA`: 要拓展的位数
- `BODY`: 执行的操作
#### math-normalize
将A规范化 至于规范化的标准 查看`calc.md`

`(math-normalize A)`


#### math-zerop
判断是不是0

### fileio
#### expand-file-name
转换`NAME`并规范为绝对路径, 设置一个默认的目录为`DEFAULT-DIRECTORY`

`(expand-file-name NAME &optional DEFAULT-DIRECTORY)`

示例:

`(expand-file-name "init.org" user-emacs-directory)` 得到emacs-home下的init.org
### buffer
#### generate-new-buffer-name
生成一个不会与现有buffer重名的buffer名称.

用于创建唯一buffer时调用

`(generate-new-buffer-name name &optional IGNORE)`

- `NAME`: 希望使用的buffer名称
- `IGNORE`: 一个buffer对象.若存在这个buffer 则在检测重名时忽略

示例
```emacs-lisp
(generate-new-buffer-name "foo")

```
若不存在foo的缓冲区 则返回foo 存在则返回foo<2>
#### set-buffer
切换操作到`BUFFER-OR-NAME` buffer. 以便后续的`insert`等操作. 注意 emacs不会切换那个buffer,仅会给elisp用.

`(set-buffer BUFFER-OR-NAME)`
#### ZV
当前buffer可访问区域的**末尾**

`#define ZV (current_buffer->zv)`
#### BEGV
当前buffer可访问区域的**开头**

`#define BEGV (current_buffer->begv)`
#### PT
当前point在buffer的位置, `+0` 是为了让`PT`不能成为左值而被赋值

`#define PT (current_buffer->pt + 0)`

### editfns
#### save-restriction
临时修改当前buffer的可见范围 执行BODY 然后恢复

`(save-restriction &rest BODY)`
#### save-excursion

`(save-excursion &rest BODY)`: 临时移动编辑器状态 执行`BODY`中的代码 然后无条件恢复. 

#### goto-char

`(goto-char POSITION)`: 设置光标到`POSITION` 例如 buffer的开始是`(point-min)`,结尾是`(point-max)` .

返回POSITION

#### point-min
返回缓冲区的开头

`(point-min)`
#### point-max
返回缓冲区的结尾

`(point-max)`
#### char-after
返回`POS`处的字符 默认为`POINT`处

`(char-after &optional POS)`
### eval
#### let
`(let VARLIST BODY)`: 设置一些变量`VARLIST` 然后执行`BODY`

#### let*
设置变量 然后执行BODY. 与let的区别是 设置的变量可以互相赋值.

`(let VARLIST BODY)`


#### while

`(while TEST BODY)`: 若`TEST != nil` 则执行BODY

示例
```emacs-lisp
(while () ())
```
#### and

`(and CONDITIONS)`: 对`CONDITIONS`逐个AND

示例

```emacs-lisp
(and t t nil)
(and t t t)
(and t nil t)
```

#### catch
执行`BODY` 允许非局部退出 有点像rust的`'label` 其中label就是TAG

`(catch TAG BODY...)`
#### if
如果`COND`非`nil` 执行`THEN` 否则 `ELSE`

`(if COND THEN ELSE)`

#### progn
合并执行`BODY1` `BODY1` 返回最后一个值

`(progn BODY...)`
#### eval_sub
执行`form` 返回表达式的值.

`Lisp_Object eval_sub (Lisp_Object form)`
#### specbind
这是C函数. 用于`specpdl`机制, 在specpdl栈上创建一个`LET`绑定条目. 至于什么是specpdl 请查看`specpdl.md`.

注意, symbol 不应该被alias.

`void specbind (Lisp_Object symbol, Lisp_Object value)`


#### record_unwind_protect系列
C函数, 用于`specpdl`机制, 在specpdl栈上创建一个反解绕保护.

1. `record_unwind_protect`: Lisp_Object参数

`void record_unwind_protect (void (*function) (Lisp_Object), Lisp_Object arg)`

unwind的时候, specpdl会调用 `function` ,然后 `arg`作为传给`function`的函数. 其他的几个record_unwind_protect都差不多, 除了mark多一个gc标记.

2. `record_unwind_protect_ptr`: 指针参数

`void record_unwind_protect_ptr (void (*function) (void *), void *arg)`

3. `record_unwind_protect_array`: 数组参数

`void record_unwind_protect_array (Lisp_Object *array, ptrdiff_t nelts)`

4. `record_unwind_protect_ptr_mark`: GC标记函数

```c
/* Like `record_unwind_protect_ptr', but also specifies a function
   for GC-marking Lisp objects only reachable through ARG.  */
void
record_unwind_protect_ptr_mark (void (*function) (void *), void *arg,
				void (*mark) (void *))
```

5. 还有其他的 都分别对应`specbind_tag`的内容
#### unbind_to
反解绑与执行保护, 用于`specpdl`机制.

弹出到specpdl栈的`count`位置, 然后返回`value`.

`Lisp_Object unbind_to (specpdl_ref count, Lisp_Object value)`
#### unwind-protect
使用`specpdl`机制保护变量,无论`BODYFORM`是正常结束 抛出错误 还是非局部跳转 `UNWINDFORMS`都会执行 同时返回 `BODYFORM`的返回值.

相当于无论`BODYFORM`怎么样,都用`UNWINDFORMS`来善后

`(unwind-protect BODYFORM UNWINDFORMS...)`

#### prog-ignore
顺序执行BODY,不管它的返回值.

`void prog_ignore (Lisp_Object body)`
### subr
#### not
`(not OBJECT)`: 取反

示例

```emacs-lisp
(not nil)
```
#### dotimes
循环固定次数 类似rust的 for i in 0..len.

`(dotimes (VAR COUNT [RESULT]) BODY...)`
#### when
若`COND`为非nil 执行BODY 否则返回nil

`(when COND &reset BODY)`
#### when-let
在`SPEC`中绑定变量 并条件执行`BODY`

`(when-let SPEC &rest BODY)`
#### derived-mode-p
判断当前Major模式是否是某个Mode的子Mode

`(derived-mode-p &reset MODES)`

#### if-let
绑定变量到`SPEC` 然后执行`THEN`

`(if-let SPEC THEN &rest ELSE)`
#### with-current-buffer
临时切换到`BUFFER-OR-NAME`执行`BODY` 然后回到当前buffer

`(with-current-buffer BUFFER-OR-NAME &reset BODY)`
### search
Emacs内部会维护一个全局的`match data` 底层为`current_thread->m_search_regs` 保存最近一次成功搜索的结果.

当REGEXP为纯字符串匹配时 尝试使用Boyer-Moore算法.



#### re-search-forward
向后搜索REGEXP正则表达式. 移动光标到匹配结果的结尾
`(re-search-forward REGEXP &optional BOUND NOERROR COUNT)`

可选参数
- BOUND 代表 搜索不超过这个范围 BOUND是缓冲区的绝对位置
- NOERROR 错误处理
  - 若为nil 产生error
  - 若为t 失败后point不移动
  - 如果不是t或者nil 失败后point移动到搜索边界
- COUNT 指定搜索方向与搜索个数 正数为前 负数为反向搜 

```emacs-lisp
one
(re-search-forward "one" -20 nil -1)


one 
(re-search-forward "one" 20 nil -1)

one 
(re-search-forward "one" 20 nil -2)

;; 报错 因为BOUND=20的话 我们现在在缓冲区的几百行 如果往后搜索必然>20
(re-search-forward "one" 20)

(re-search-forward "one" (+ (point) 20)) 
one

(re-search-forward "one" nil 1)
two
```


#### match-beginning
返回最后一次匹配的**开头**的位置

`(match-beginning SUBEXP)`

- SUBEXP: 返回第SUBEXP个正则表达式组的位置
#### match-end
返回最后一次匹配的**结尾**的位置

`(match-end SUBEXP)`

- SUBEXP: 返回第SUBEXP个正则表达式组的位置
#### match-data
取出`match-data`.

`(match-data &optional INTEGERS REUSE RESEAT)`

- `INTEGERS`: 默认情况下 返回值是marker 使用这个参数代表返回整数位置.
- `REUSE`: 性能优化. 传一个`list`进去直接原地修改
- `RESEAT`: 如果 REUSE 里面以前存的是 marker,而现在准备复用这个 list.
### fns
#### length
返回向量 列表或者序列的长度

`(length SEQUENCE)`

#### sort
稳定排序序列

`(sort SEQ &key KEY LESSP REVERSE IN-PLACE)`

- SEQ: 排序的序列
- &key: 标记后面的参数为按照名字传
- KEY: 用于比较的键值
- LESSP: 决定如何比较
- REVERSE: 是否倒序
- IN-PLACE: 是否原址

示例
```emacs-lisp
(let ((list [0 1 3 2 4 4 0 2])) 
	(sort list)
)
```
#### string-distance
返回`STRING1` 与 `STRING2` 之间的Levenshetin距离

Levenshetin距离指的是: 将`STRING1`变换为`STRING2`所需进行的 `删除` `插入` `替换` 总次数

`(string-distance STRING1 STRING2 BYTECOMPARE)`

- 若BYTECOMPARE为nil或忽略 则以字符为单位计算距离 否则以字节
#### mapcar
相当于rust的 `Iterator.map(|x| f).collect::<List>()`

`(mapcar FUNCTION SEQUENCE)`

对序列`SEQUENCE`中的每个元素应用`FUNCTION` 然后返回一个List.
#### memq
判断`ELT`在不在list里, 在的话返回它一直到末尾`[idx..]`, 不在返回`nil`.

`(memq ELT LIST)`
#### assoc
在`ALIST`中,找到第一个与`KEY`相等的键. 然后返回`(key . value)`

`(assoc KEY ALIST &optional TESTFN)`
### alloc
#### make-vector
创建向量 长度`length` 初始化为`init`

`(make-vector length init)`
### data
#### eq
若两个对象是相同的Lisp对象 则返回t

`(eq OBJ1 OBJ2)`
#### aset
设置数组`ARRAY` 索引`IDX`上的值为`NEWELT`

`(aset ARRAY IDX NEWELT)`

#### aref
获取数组`ARRAY` 索引`IDX`上的值

`(aref ARRAY IDX)`
#### car
获取LIST的`car`

`car`代表`cons-cell`的car

`(car LIST)`
#### cdr
获取LIST的`cdr`

`(cdr LIST)`
### syntax.c
#### parse-partial-sexp
从FROM到TO扫描lisp代码返回一个状态列表

`(parse-partial-sexp FROM TO &optional TARGETDEPTH STOPBEFORE OLDSTATE COMMENTSTOP)`

- FROM: 开始解析的位置
- TO: 解析到的位置
- TARGETDEPTH: 最大目标括号深度
- STOPBEFORE: 遇到一个sexp开始字符时停止
- OLDSTATE: 从已有parser状态继续解析
- COMMENTSTOP: 遇到commet/string停止

状态列表具有12个字段

- 0 括号深度
- 1 当前所在最内层lisp的开括号位置
- 2 最近一个完整sexp结束的位置
- 3 当前是否在字符串里
- 4 当前是不是在注释里
- 5 是否读到的是quote
- 6 扫描过程中遇到的最低括号深度
- 7 注释的类型 比如行注释 块注释
- 8 当前comment或者string开始的位置
- 9 当前打开的括号的位置
- 10 处理两个字符组成的syntax 比如//这种 只扫到第一个/ 还没扫到第二个/

### syntax.el
#### syntax-ppss
返回`POS`处 或者 `point`处的语法解析状态 同时会**缓存**这个状态 返回一个和`parse-partial-sexp`一样的列表.

> 注意 在syntax-ppss中的parse-partial-sexp列表 不保证2和6字段的正确性

`(syntax-ppss &optional POS)`

### process.c
### process.h
#### Lisp_Process
进程或者网络连接的信息

```c
struct Lisp_Process
```

`Lisp_Process`里面存放有多种进程状态 包括Lisp层 OS层 各种bit-flag
#### PROCESSP
判断这个lisp对象是不是进程

`INLINE bool
PROCESSP (Lisp_Object a)`
#### XPROCESS
转换`Lisp_Object`为 `Lisp_Process`

`INLINE struct Lisp_Process *
XPROCESS (Lisp_Object a)`
### insdel
#### insert_from_string_before_markers

