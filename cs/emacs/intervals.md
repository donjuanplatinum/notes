# 区间树
Emacs里一个比较核心的数据结构.

- `src/intervals.c`: 区间树. 主要使用类似AVL的权重平衡. 主要用于: 

Emacs里 缓冲区的每个字符可能有不同的属性, 而维护相同属性字符属于什么区间的就是intervals.c做的.
  


- `src/itree.c`: 增强的区间树实现.  主要使用了红黑树以及区间增强.

真正用于区间重叠查询的.用于管理Emacs的overlays.


## intervals

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
