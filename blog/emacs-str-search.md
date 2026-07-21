# Emacs字符串搜索
EMACSw为搜索暴露了很多接口

- `re-search-forward`
- `re-search-backward`
- `search-forward`
...

本文来探究Emacs的这些接口的实现与算法. 它们定义于search.c

Emacs内部会维护一个全局的`match data` 底层为`current_thread->m_search_regs` 保存最近一次成功搜索的结果.



我们主要研究这两个函数
- `re-search-forward`
- `search-forward`

```c
DEFUN ("re-search-forward", Fre_search_forward, Sre_search_forward, 1, 4,
       "sRE search: ",
       doc: /* Search forward from point for regular expression REGEXP.
Set point to the end of the occurrence found, and return point.
The optional second argument BOUND is a buffer position that bounds
  the search.  The match found must not end after that position.  A
  value of nil means search to the end of the accessible portion of
  the buffer.
The optional third argument NOERROR indicates how errors are handled
  when the search fails: if it is nil or omitted, emit an error; if
  it is t, simply return nil and do nothing; if it is neither nil nor
  t, move to the limit of search and return nil.
The optional fourth argument COUNT is a number that indicates the
  search direction and the number of occurrences to search for.  If it
  is positive, search forward for COUNT successive occurrences; if it
  is negative, search backward, instead of forward, for -COUNT
  occurrences.  A value of nil means the same as 1.
With COUNT positive/negative, the match found is the COUNTth/-COUNTth
  one in the buffer located entirely after/before the origin of the
  search.

Search case-sensitivity is determined by the value of the variable
`case-fold-search', which see.

See also the functions `match-beginning', `match-end', `match-string',
and `replace-match'.  */)
  (Lisp_Object regexp, Lisp_Object bound, Lisp_Object noerror, Lisp_Object count)
{
  return search_command (regexp, bound, noerror, count, 1, true, false);
}
```

```c
DEFUN ("search-forward", Fsearch_forward, Ssearch_forward, 1, 4, "MSearch: ",
       doc: /* Search forward from point for STRING.
Set point to the end of the occurrence found, and return point.
The optional second argument BOUND is a buffer position that bounds
  the search.  The match found must not end after that position.  A
  value of nil means search to the end of the accessible portion of
  the buffer.
The optional third argument NOERROR indicates how errors are handled
  when the search fails: if it is nil or omitted, emit an error; if
  it is t, simply return nil and do nothing; if it is neither nil nor
  t, move to the limit of search and return nil.
The optional fourth argument COUNT is a number that indicates the
  search direction and the number of occurrences to search for.  If it
  is positive, search forward for COUNT successive occurrences; if it
  is negative, search backward, instead of forward, for -COUNT
  occurrences.  A value of nil means the same as 1.
With COUNT positive/negative, the match found is the COUNTth/-COUNTth
  one in the buffer located entirely after/before the origin of the
  search.

Search case-sensitivity is determined by the value of the variable
`case-fold-search', which see.

See also the functions `match-beginning', `match-end', `match-string',
and `replace-match'.  */)
  (Lisp_Object string, Lisp_Object bound, Lisp_Object noerror, Lisp_Object count)
{
  return search_command (string, bound, noerror, count, 1, false, false);
}
```

我们发现它们都调用的`search_command`函数.

## search_command
值得注意的是 在目前emacs30版本 这个函数仍然是包含1994当年Richard Stallman和92年Jim的提交

```c
static Lisp_Object
search_command (Lisp_Object string, Lisp_Object bound, Lisp_Object noerror,
		Lisp_Object count, int direction, bool RE, bool posix)
{
  // 最终搜索结果 即point跳转位置
  EMACS_INT np;
  EMACS_INT lim;
  ptrdiff_t lim_byte;
  EMACS_INT n = direction;

  if (!NILP (count))
    {
      CHECK_FIXNUM (count);
      n *= XFIXNUM (count);
    }

  CHECK_STRING (string);
  if (NILP (bound))
    {
	  // 正向搜索
      if (n > 0)
	lim = ZV, lim_byte = ZV_BYTE;
      // 反向搜索
      else
	lim = BEGV, lim_byte = BEGV_BYTE;
    }
  else
    {
	  
      lim = fix_position (bound);
	  // 正向搜索必须 point <= bound, 反向搜索必须bound <= point
      if (n > 0 ? lim < PT : lim > PT)
	error ("Invalid search bound (wrong side of point)");
      if (lim > ZV)
	lim = ZV, lim_byte = ZV_BYTE;
      else if (lim < BEGV)
	lim = BEGV, lim_byte = BEGV_BYTE;
      else
	lim_byte = CHAR_TO_BYTE (lim);
    }

  /* This is so set_image_of_range_1 in regex-emacs.c can find the EQV
     table.  */
  // 准备等价字符表 因为emacs默认情况下 abc也会匹配ABC aBC ..
  set_char_table_extras (BVAR (current_buffer, case_canon_table), 2,
			 BVAR (current_buffer, case_eqv_table));
  
  np = search_buffer (string, PT, PT_BYTE, lim, lim_byte, n, RE,
		      (!NILP (Vcase_fold_search)
		       ? BVAR (current_buffer, case_canon_table)
		       : Qnil),
		      (!NILP (Vcase_fold_search)
		       ? BVAR (current_buffer, case_eqv_table)
		       : Qnil),
		      posix);
  if (np <= 0)
    {
      if (NILP (noerror))
	xsignal1 (Qsearch_failed, string);

      if (!EQ (noerror, Qt))
	{
	  eassert (BEGV <= lim && lim <= ZV);
	  SET_PT_BOTH (lim, lim_byte);
	  return Qnil;
#if 0 /* This would be clean, but maybe programs depend on
	 a value of nil here.  */
	  np = lim;
#endif
	}
      else
	return Qnil;
    }

  eassert (BEGV <= np && np <= ZV);
  SET_PT (np);

  return make_fixnum (np);
}
```
## search_buffer
