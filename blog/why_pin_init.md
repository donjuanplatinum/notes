# 为何需要pin_init
这里的pin_init指的是Linux内核的rust支持中的`rust/pin_init`.

pin_init的目标是: 可以原地初始化结构体 且Pin住.

## 为什么linux的rust支持需要pin_init


在rust中 由于所有权的move 很多类型在内存中是默认可能移动的. 

在linux内核中 链表是**侵入性**的: 假设 `A <-> B <-> C` 如果此时move一次. B被Move了 那么A的next和C的prev直接炸了. 所以要Pin住


