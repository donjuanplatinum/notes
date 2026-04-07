# Valgrind
Valgrind是一个工具集 用于检测**内存错误** **内存泄露** **并发竞争** **CPU缓存命中** **函数内联** **调用关系** **堆栈情况** ...

Valigrind有几个子工具
- cachegrind: CPU缓存命中分析. 可以用来调试算法是否Cache友好,看函数是否内联 ,缓存是否命中
- callrind: 分析程序调用关系和执行次数(KDE有个GUI工具kcachegrind用来配合分析)
- helgrind: 检测多线程程序中的竞争条件
- massif: 堆内存分析
- memcheck: 检测内存错误 内存泄漏 越界访问 重复释放
