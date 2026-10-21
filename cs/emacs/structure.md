# 数据结构
Emacs内置的数据结构.
## cons cell
Elisp的`cons cell` 是很多数据结构的基础.

定义于`src/alloc.c`

一个`cons cell`有两个字段:

- `CAR`
- `CDR`

我们可以用`car` 与`cdr`函数取出它们.
```emacs-lisp
(cons 1 2) ;; (1 . 2)
(car '(1 . 2)) ;; 1
(cdr '(1 . 2)) ;; 2
```

有几个方便的函数:

取出

- `car`: 取出CAR
- `cdr`: 取出CDR
- `cadr`: `(car (cdr x))`
- `caddr`: `(car (cdr (cdr x)))`
- `caar`: `(car (car x))`
- `cddr`: `(cdr (cdr x))`
- `cadar`: `(car (cdr (car x)))`

## list
列表就是由`cons cell`构成的数组.

注意 这个列表元素可以是不同类型.

```emacs-lisp
(list 1 2 3 "123")
```

实际上底层是一个`cons cell`

```emacs-lisp
(cons 1 (cons
	 2 (cons
	    3 (cons "123" nil))))
```

常用函数
- `list`: 创建list
- `(make-list len init)`: 相当于rust的 `[init;len]`
- `append`: 拼接链表
- `(member ele list)`: 在list中用equal查找ele
- `(memq ele list)`: 在list中用eq查找ele
- `(mapcar func seq)`: 相当于rust的 `seq.for_each(|x| func(x))`然后返回新的集合
- `(mapc func seq)`: 相当于rust的 `seq.for_each(|x| func(x))`但是返回原序列
- `push/pop`
## alist
可以这么理解

list是 `[T]`, alist是`[(K,V)]`.

`alist`底层也是`cons cell`,

```emacs-lisp
'(1 2 3) ;; list
'((a . 10) (b . 20) (c . 30)) ;; alist
```


## 哈希表
HashTable

- `make-hash-table`: 创建哈希表
- `gethash`: `map.get()`
- `puthash`: `map.insert()`
- `remhash`: `map.remove()`

## 区间树
Emacs里一个比较核心的数据结构.

- `src/intervals.c`: 区间树. 主要使用类似AVL的权重平衡. 主要用于: 

Emacs里 缓冲区的每个字符可能有不同的属性, 而维护相同属性字符属于什么区间的就是intervals.c做的.
  


- `src/itree.c`: 增强的区间树实现.  主要使用了红黑树以及区间增强.

真正用于区间重叠查询的.用于管理Emacs的overlays.


### intervals

```c

struct interval
{
  /* The first group of entries deal with the tree structure.  */
  ptrdiff_t total_length;       /* Length of myself and both children.  */
  ptrdiff_t position;	        /* Cache of interval's character position.  */
                                /* This field is valid in the final
                                   target interval returned by
                                   find_interval, next_interval,
                                   previous_interval and
                                   update_interval.  It cannot be
                                   depended upon in any intermediate
                                   intervals traversed by these
                                   functions, or any other
                                   interval. */
  struct interval *left;	/* Intervals which precede me.  */
  struct interval *right;	/* Intervals which succeed me.  */

  /* Parent in the tree, or the Lisp_Object containing this interval tree.  */
  union
  {
    struct interval *interval;
    Lisp_Object obj;
  } up;
  bool_bf up_obj : 1;

  bool_bf gcmarkbit : 1;

  /* The remaining components are `properties' of the interval.
     The first four are duplicates for things which can be on the list,
     for purposes of speed.  */

  bool_bf write_protect : 1;	    /* True means can't modify.  */
  bool_bf visible : 1;		    /* False means don't display.  */
  bool_bf front_sticky : 1;	    /* True means text inserted just
				       before this interval goes into it.  */
  bool_bf rear_sticky : 1;	    /* Likewise for just after it.  */
  Lisp_Object plist;		    /* Other properties.  */
};
```
