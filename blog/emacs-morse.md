# emacs Morse电码
emacs自带morse电码的操作函数 `unmorse-region` 和 `morse-region`

其定义于`morse.el` `/usr/share/emacs/30.1/lisp/play/morse.el`

## morse.el
在morse.el中 定义了morse-code的list
```emacs-lisp
(defvar morse-code '(("a" . ".-")
		     ("b" . "-...")
		     ("c" . "-.-.")
		     ("d" . "-..")
		     ("e" . ".")
		     ("f" . "..-.")
		     ("g" . "--.")
		     ("h" . "....")
		     ("i" . "..")
		     ("j" . ".---")
		     ("k" . "-.-")
		     ("l" . ".-..")
		     ("m" . "--")
		     ("n" . "-.")
		     ("o" . "---")
		     ("p" . ".--.")
		     ("q" . "--.-")
		     ("r" . ".-.")
		     ("s" . "...")
		     ("t" . "-")
		     ("u" . "..-")
		     ("v" . "...-")
		     ("w" . ".--")
		     ("x" . "-..-")
		     ("y" . "-.--")
		     ("z" . "--..")
		     ;; Punctuation
		     ("=" . "-...-")
		     ("?" . "..--..")
		     ("/" . "-..-.")
		     ("," . "--..--")
		     ("." . ".-.-.-")
		     (":" . "---...")
		     ("'" . ".----.")
		     ("-" . "-....-")
		     ("(" . "-.--.-")
		     (")" . "-.--.-")
		     ;; Numbers
		     ("0" . "-----")
		     ("1" . ".----")
		     ("2" . "..---")
		     ("3" . "...--")
		     ("4" . "....-")
		     ("5" . ".....")
		     ("6" . "-....")
		     ("7" . "--...")
		     ("8" . "---..")
		     ("9" . "----.")
		     ;; Non-ASCII
		     ("ä" . ".-.-")
		     ("æ" . ".-.-")
		     ("á" . ".--.-")
		     ("å" . ".--.-")
		     ("ß" . ".../...")  ; also ...--..
		     ("é" . "..-..")
		     ("ñ" . "--.--")
		     ("ö" . "---.")
		     ("ø" . "---.")
		     ("ü" . "..--")
		     ;; Recently standardized
		     ("@" . ".--.-."))
  "Morse code character set.")
			 ```




定义了`morse-region`函数
``` emacs-lisp
(defun morse-region (beg end)
  "将区域中的纯文本转换为摩尔斯电码。
参见：<https://en.wikipedia.org/wiki/Morse_code>。"
  (interactive "*r")  ; 交互声明：若缓冲区只读则报错，并获取选中区域的起止位置作为参数
  (if (integerp end)  ; 若end是整数（即位置值）
      (setq end (copy-marker end)))  ; 将其转换为标记（marker），避免位置因文本修改而失效
  (save-excursion  ; 保存当前光标位置和缓冲区状态，执行完代码后自动恢复
    (let ((sep "")  ; 初始化分隔符为空字符串（用于分隔不同字符的摩尔斯电码）
	  str morse)  ; 声明变量：str用于存储当前字符，morse用于存储匹配的摩尔斯电码
      (goto-char beg)  ; 将光标移动到区域的起始位置
      (while (< (point) end)  ; 循环：只要光标位置在区域结束位置之前就持续执行
	(setq str (downcase (buffer-substring (point) (1+ (point)))))  ; 取当前光标处的字符并转为小写
	(cond ((looking-at "\\s-+")  ; 条件1：若当前位置是一个或多个空白字符
	       (goto-char (match-end 0))  ; 光标跳至空白字符的末尾
	       (setq sep ""))  ; 重置分隔符为空（空白字符后不添加分隔符）
	      ((setq morse (assoc str morse-code))  ; 条件2：若当前字符在morse-code（摩尔斯码对照表）中存在匹配
	       (delete-char 1)  ; 删除原字符
	       (insert-before-markers sep (cdr morse))  ; 插入分隔符+对应的摩尔斯电码
	       (setq sep "/"))  ; 将分隔符设为"/"（用于下一个字符的摩尔斯电码分隔）
	      (t  ; 条件3：其他未匹配的字符
	       (forward-char 1)  ; 光标向前移动1位，跳过该字符
	       (setq sep "")))))))  ; 重置分隔符为空
```
