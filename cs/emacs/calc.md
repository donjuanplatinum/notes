# Calc子系统
这是Emacs非常非常强大的数值计算 数学计算 代数**计算器**.

对于详细的elisp接口 请查看: Elisp章节.
## 架构设计
calc子系统位于`lisp/calc`文件夹.

它的入口为`lisp/calc/calc.el`, 扩展功能入口为`lisp/calc/calc-ext.el`.

这样设计的目的是, 使用`autoload`机制 可以**懒加载**计算器功能.

入口与基础功能:

- `calc.el` 里面主要定义了各种`defcustom`的用户设置 以及对函数的导出.
- `calc-ext.el` calc扩展层的导出
- `calc-macs.el` calc的核心宏与辅助函数
- `calc-loaddef.el` 自动生成的声明文件
- `calc-menu.el` Calc的菜单定义
- `calc-mode.el` Calc的显示与工作模式 比如格式 进制 对齐 等
- `calc-keypd.el` 鼠标可操作的数字键盘
- `calc-misc.el` 杂项功能 比如打开帮助 Info之类的
- `calc-help.el` 帮助系统
- `calc-stuff.el` 杂项内部工具 比如递归深度 缓存清理 随机数 矩阵等缓存

输入解析等语言功能

- `calc-aent.el` 代数表达式输入
- `calc-incom.el` 复杂数据结构的增量解析 向量 复数 逗号 分号
- `calc-lang.el` calc表达式语言设置 处理普通 扁平 大语言模式 括号逗号之类的
- `calccomp.el` 把内部表达式转换为带括号、分数、上下标、向量等 格式的可显示结构
- `calc-embed.el`：Embedded Calc；把 Calc 公式嵌入普通编辑缓冲区，并负责公式识别、重算
  和显示。
- `calc-trail`.el：Calc trail（历史计算轨迹）的浏览、滚动、搜索、前后跳转和窗口切换。
- `calc-undo.el`：Calc 专用 undo/redo、最后参数恢复，以及与 Calc 栈状态关联的撤销处理。
- `calc-sel.el`：在 Calc 表达式中选择子表达式、缓存选择位置、扩展或重新选择区域。
- `calcsel2.el`：基于选择区域的结构化编辑操作，例如交换、跳转、隔离、分配、合并、取负

数值运算

- `calc-arith.el` 运算的核心 定义了标量 向量 矩阵 四舍五入 比较
- `calc-math.el` 基础数学函数与数值算法 平方根 对数 指数 三角 双曲
- `calc-bin.el` 二进制和位运算
- `calc-frac.el` 分数运算
- `calc-cplx.el` 复数运算
- `calc-comb.el` 组合数学
- `calc-funcs.el`特殊函数
- `calc-fin.el` 金融函数

代数与符号学

- `calc-alg.el` 代数化简模块, 比如展开 因式分解 幂展开
- `calcalg2.el` 导数 积分 求和 乘积 解方程 Taylor展开
- `calcalg3.el` 更多代数 数值分析功能 比如插值 曲线模型
- `calc-poly.el` 多项式运算
- `calc-rewr.el` 按模式匹配重写表达式
- `calc-rules.el` 预定义的代数重写规则集 交换律 结合分配 合并 负号 逆 因式分解 积分后处理
- `calc-prog.el` calc内部的可编程功能 
- `calc-map.el` 高阶函数与集合操作 内积 外积等

线性代数

- `calc-vec.el` 向量构造 处理 打包 解包 对角矩阵 等
- `calc-mtx.el` 矩阵 矩阵乘法 转置 迹 行列式 LU分解
- `calc-stat.el` 向量统计函数
- `calc-units.el` 物理单位
- `calc-graph.el` 图形输出 与gnuplot交互
- `calc-nlfit.el` 非线性曲线拟合


### 契约
calc子系统里

注释 `[x y z]` 代表**类型契约**.

- 大写代表已经归一化了
- 小写代表可能没归一化
### 精确与近似
calc子系统中 类型分为 `exact`与`inexact`

整数 分数都是`exact`

但是浮点数是`inexact`
### 规范化
规范化对后面的积分 化简系统有非常大的作用.

它定义了 符号的 **最简状态**.

规范化的函数为`(math-normalize A)`.

1. 整数: 已经是规范的
2. 分数: 必须规范化

`(frac NUM DEN)`

必须`DEN > 1` 且**已约分**.

而且如果是整数 比如4/2 那么必须化简为整数

3. 浮点: calc的float不是elisp的浮点 而是自己的

`(float NUM EXP)`

即为: $NUM \times 10^{EXP}$.

calc要求: 

- `NUM`不能是10的倍数.
- `NUM`的绝对值必须小于: $10^{calc-internal-prec}$,也就是这里规范了prec的精度.
- `zero` 必须是 `'(float 0 0)`.

4. 复数: `(cplx REAL IMAG)`

这里的归一化条件只有: `IMAG`不为0 不然就是实数.

5. 极坐标: `(polar R THETA)`

必须 `R > 0` 且 `THETA != 0 != 180`

6. 向量: `(vec A B C ...)`

7. 时间: `(hms H M S)` 这个不多说 看calc.el即可

8. 日期 不多说

9. 正负: `(sdev X SIGMA)` 这个表示 $X \pm \sigma$

这个要求 `SIGMA > 0`

10. 数学区间: `(intv MASK LO HI)`

`MASK`代表什么`前开后闭`之类的

- 0: `()`
- 1: `(]`
- 2: `[)`
- 3: `[]`

这个不能有 `LO = HI` 不然区间要么是整数要么是空区间

11. 高斯同余: `(mod N M)`

要求 `0 \leq N < M`

12. 
### 语言嵌入
calc可以在其他的语言里嵌入数学表达式 然后让calc去交互式的算.

这个子系统位于 `lisp/calc/calc-embd.el`


### 函数
定义于`lisp/calc/calc-funcs.el`, 被`lisp/calc/calc-ext.el`加载 `autoload`.

它的函数封装接口是这样的 我以`calc-erf` 误差函数举例:

```emacs-lisp
(defun calc-erf (arg)
  (interactive "P")
  (calc-slow-wrapper
   (if (calc-is-inverse)
       (calc-unary-op "erfc" 'calcFunc-erfc arg)
     (calc-unary-op "erf" 'calcFunc-erf arg))))
```

它会去条件调用`calcFunc-erfc`或者`calcFunc-erf`. 也就是说

- **calcFunc-xxx**是`calc-funcs`的底层数学实现.

值得注意的是

- 对于递归的算法, 使用`(math-working)` 函数标记进度.
- `(math-with-extra-prec)` 在计算内部临时提高精度

