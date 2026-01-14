# Nael
Emacs的Lean模式

## Key
| 快捷键  | 作用               | 命令             |
|---------|--------------------|------------------|
| C-c C-a | 启用缩写           | abbrev-mode      |
| C-c C-k | 回显缩写           | nael-abbrev-help |
| C-x '   | 展开小数点前的缩写 | expand-abbrev    |
## unicode
可以通过\开头的类似latex的语法打出

比如 \in
## eval
可以通过在开启lsp或者eglot后 输入#eval关键字来**实时求值**

```lean
#eval IO.println "你好"
```
