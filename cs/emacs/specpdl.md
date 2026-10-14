# Specpdl机制
special binding & protection list 机制.

specpdl是一个手动管理的栈结构, 用于追踪三种信息:

1. 动态的let binding
2. 方案解绕保护 unwind-protects
3. 回溯信息 backtrace

## 核心数据结构
### specbind_tag
保护的类型

定义于 `src/lisp.h`. 

大概分为: 函数 ,数组, 指针, int, point位置, 无参数保护函数, backtrace, 模块运行时, 模块环境, 动态let, 局部let, 全局let.
```c
enum specbind_tag {
  SPECPDL_UNWIND,		/* An unwind_protect function on Lisp_Object.  */
  SPECPDL_UNWIND_ARRAY,		/* Likewise, on an array that needs freeing.
				   Its elements are potential Lisp_Objects.  */
  SPECPDL_UNWIND_PTR,		/* Likewise, on void *.  */
  SPECPDL_UNWIND_INT,		/* Likewise, on int.  */
  SPECPDL_UNWIND_INTMAX,	/* Likewise, on intmax_t.  */
  SPECPDL_UNWIND_EXCURSION,	/* Likewise, on an excursion.  */
  SPECPDL_UNWIND_VOID,		/* Likewise, with no arg.  */
  SPECPDL_BACKTRACE,		/* An element of the backtrace.  */
  SPECPDL_NOP,			/* A filler.  */
#ifdef HAVE_MODULES
  SPECPDL_MODULE_RUNTIME,       /* A live module runtime.  */
  SPECPDL_MODULE_ENVIRONMENT,   /* A live module environment.  */
#endif /* !HAVE_MODULES */
  SPECPDL_LET,			/* A plain and simple dynamic let-binding.  */
  /* Tags greater than SPECPDL_LET must be "subkinds" of LET.  */
  SPECPDL_LET_LOCAL,		/* A buffer-local let-binding.  */
  SPECPDL_LET_DEFAULT		/* A global binding for a localized var.  */
};
```


### specbinding
栈上的条目

定义于`src/lisp.h` .

```c
union specbinding
  {
    /* Aligning similar members consistently might help efficiency slightly
       (Bug#31996#25).  */
    ENUM_BF (specbind_tag) kind : CHAR_BIT;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      void (*func) (Lisp_Object);
      Lisp_Object arg;
      EMACS_INT eval_depth;
    } unwind;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      ptrdiff_t nelts;
      Lisp_Object *array;
    } unwind_array;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      void (*func) (void *);	/* Unwind function.  */
      void *arg;
      void (*mark) (void *);	/* GC mark function (if non-null).  */
    } unwind_ptr;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      void (*func) (int);
      int arg;
    } unwind_int;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      void (*func) (intmax_t);
      intmax_t arg;
    } unwind_intmax;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      Lisp_Object marker, window;
    } unwind_excursion;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      void (*func) (void);
    } unwind_void;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      /* `where' is not used in the case of SPECPDL_LET,
	 unless the symbol is forwarded to a KBOARD.  */
      Lisp_Object symbol, old_value;
      union {
	/* KBOARD object to which SYMBOL forwards, in the case of
	   SPECPDL_LET.  */
	KBOARD *kbd;

	/* Buffer otherwise.  */
	Lisp_Object buf;
      } where;
    } let;
    struct {
      ENUM_BF (specbind_tag) kind : CHAR_BIT;
      bool_bf debug_on_exit : 1;
      Lisp_Object function;
      Lisp_Object *args;
      ptrdiff_t nargs;
    } bt;
  };

```
### specpdl_ref
指向specpdl栈中的某个条目的抽象引用,单位是字节而不是数组索引

定义于`src/lisp.h`

```c
/* Abstract reference to a specpdl entry.
   The number is always a multiple of sizeof (union specbinding).  */
#ifdef WRAP_SPECPDL_REF
/* Use a proper type for specpdl_ref if it does not make the code slower,
   since the type checking is quite useful.  */
typedef struct { ptrdiff_t bytes; } specpdl_ref;
#else
typedef ptrdiff_t specpdl_ref;
#endif
```


## 接口
具体请看`elisp.md`,这里仅列出

- `specbind`: 用于在specpdl栈上添加一个let绑定.
- `record_unwind_protect*`系列: 在specpdl栈上注册反解绕处理器.
- `unbind_to`: 从当前`specpdl`栈指针回退到之前保存的位置
- `SPECPDL_INDEX`: 记录当前`specpdl`的栈位置 方便到时候`unbind_to`的时候直接恢复到这里.
- `unwind-protect`: 保护BODY 最后无论如何执行清理.
## GC
为什么需要 `unwind_ptr` 与`record_unwind_protect_ptr_mark` 这类GC机制的specpdl呢?

我们考虑这个场景:

```c
struct context {
	Lisp_Object a_lisp_obj;
	int a;
	void *other_data;
};
```

我们想要用specpdl保护它:

```c
struct context *ctx = xmalloc(sizeof(*ctx));
ctx->a_lisp_obj = Fcons (Qnil,Qnil);

record_unwind_protect_ptr(cleanup_func, (void *)ctx);
```

这里使用的是ptr 没有使用mark.

那么当GC扫描到specpdl栈 扫到了`SPECPDL_UNWIND_PTR { func: cleanup_func , arg: (void *)ctx}`

但是GC不会去分析这个ctx指向什么 也就是说: ctx中的`a_lisp_obj`是孤立的 没有被引用. 它们会被GC释放.

如果添加了mark:

```c
static void context_mark (void *arg){
	struct context *ctx  = arg;
	
	make_objects (ctx->a_lisp_obj);
}
```

```c
struct context *ctx = xmalloc(sizeof(*ctx));
ctx->a_lisp_obj = Fcons (Qnil,Qnil);

record_unwind_protect_ptr_mark(cleanup_func, (void *)ctx,context_mark);
```

那么这样 `a_lisp_obj`就是被标记的 有引用的 不会被GC识别清除.
## 示例
### ert测试经常用

这个出自`test/lisp/calc/clac-tests.el`
```emacs-lisp
(ert-deftest calc-latex-input ()
  ;; Check precedence of "/" in LaTeX input mode.
  (should (equal (math-read-exprs "a+b/c*d")
                 '((+ (var a var-a) (/ (var b var-b)
                                       (* (var c var-c) (var d var-d)))))))
  (unwind-protect
      (progn
        (calc-set-language 'latex)
        (should (equal (math-read-exprs "a+b/c*d")
                 '((+ (var a var-a) (/ (var b var-b)
                                       (* (var c var-c) (var d var-d)))))))
        (should (equal (math-read-exprs "a+b\\over c*d")
                       '((/ (+ (var a var-a) (var b var-b))
                            (* (var c var-c) (var d var-d))))))
        (should (equal (math-read-exprs "a/b/c")
                       '((/ (/ (var a var-a) (var b var-b))
                            (var c var-c))))))
    (calc-set-language nil)))
```

这里的`(unwind-protect)`保护了里面的calc-set-language所绑定的变量, 最后无论如何调用`calc-set-language nil`.
### non-local exit恢复
