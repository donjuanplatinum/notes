# Emacs
Emacs的基本概念与操作

Emacs是一款基于ELisp(Emacs Lisp)的编辑器: 你可以通过Lisp做到几乎完全的自定义这个编辑器

在Emacs这款编辑器中 每个快捷键都绑定的对应的命令(interactive的ELisp函数)

其中 `C-x` `M-x` 分别代表按住Ctrl和按住Meta(在一般的键盘为Alt和Esc) 然后按下x

- 若想查看基础教学可以按下`C-h t` 
- 查看某个快捷键对应的命令`C-h k`
- 查看某个函数的定义`C-h f`
## 移动与编辑
| Key             | Mean                       | Command                                            |
|-----------------|----------------------------|----------------------------------------------------|
| C-p/C-n/C-b/C-f | 上下左右                   | previous-line/next-line/backward-char/forward-char |
| C-v/M-v         | 上下翻页(一整个屏幕的行数) | scroll-up-command/scroll-down-command              |
| M-</M->         | 缓冲区的开头/结尾          | beginning-of-buffer/end-of-buffer                  |
| M-f/M-b         | 向左/右一个单词            | forward-word/backwrad-word                         |
| C-a/C-e         | 行的开头/结尾              | move-beginning-of-line/move-end-of-line            |
| C-k             | 删除一行                   | kill-line                                          |
| C-d             | 删除光标的字符             | delete-char                                        |
| M-d             | 删除后面的单词             | kill-word                                          |
| M-backspace     | 删除前面的词               | backward-kill-word                                 |
## 选择
| Key                       | Mean                                                            | Command                 |
|---------------------------|-----------------------------------------------------------------|-------------------------|
| C-SPC/C-@/C-c r(自己加的) | 开始选择(因为在很多tty C-SPC和C-@很难打出来 所以自定义了一个键) | set-mark-command        |
| C-x C-x                   | 光标移动到选择区的开头和结尾                                    | exchange-point-and-mark |
| C-x SPC/C-c m(自己加的)   | 选择矩形区域                                                    | rectangle-mark-mode     |
| M-w                       | 复制                                                            | kill-ring-save          |
| C-y                       | 粘贴                                                            | yank                        |
