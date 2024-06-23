= Typst
+ #link(<math>)[math]
 + #link(<math_expr>)[表达]
 + #link(<sym>)[符号]
= Math #label("math")
== 表达 #label("math_expr")
1. 求和
dispay(sum\_(底)^上 右) $ display(sum_(下)^上  右) $

2. 附加
attach(符号,t: 上,b: 下,tl: 左上, bl: 左下, tr: 右上, br: 右下)  $ attach(pi ,t: 上 ,b: 下 ,tl: 左 上 ,bl: 左 下 ,tr: 右 上 ,br:右 下) $

3. 括号
cases(
	delim "括号类型",
	a, \
	b, \
	c, \
	d, \
) \
括号类型 "(" "[" "{" "|" "||"
$ cases(
	delim: "[",
	a,
	b,
	c,
	d,
) $

4. 分数
frac( a, b)
$ frac( a , b) $ 


5. 矩阵
	
	mat(
		delim: "括号类型",
		1,2,3,4;
		2,2,2,3;
	)	

	$ mat(
		delim: "[",
		1,2,3,4;
		100,0,0,0;
	) $
	
		6. 根式
		平方根 sqrt(a)
		$ sqrt(a) $
		多次方根 root(a,b)
		$ root(100 , x) $

		7. 向量
		vec(delim:"括号类型",a,b,c)

		$ vec(delim:"[",a,2) $
		

		
== 符号 #label("sym")
- 花体 cal(a) $cal(a)$

			  

			  
