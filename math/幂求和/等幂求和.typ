#import "template.typ": project

#show: project.with(
  title: "形式幂级数解决幂求和问题",
  authors: (
    (name: "Donjuan Platinum(姚一飞)", 
    email: "826149163@qq.com",
    affiliation: "Thief Union,Barrensea", 
    postal: "Wuhan", 
    phone: "19945051817",
    github: "https://github.com/donjuanplatinum",
    ),
    (name: "Luca Xuan(魏婧雯)", 
    affiliation: "Thief Union(会长)", 
    postal: "Wuhan",
    email: "",
    phone: "",
    github: "",
    ),
    (name: "Coco Lee(李鑫钰)", 
    affiliation: "Thief Union", 
    postal: "Wuhan",
    email: "",
    phone: "",
    github: "",
    ),
    (name: "WenXia Ji(纪文霞)", 
    affiliation: "Thief Union", 
    postal: "Wuhan",
    email: "",
    phone: "",
    github: "",
    ),
    (name: "Sniper Wang(王文鼎)", 
    affiliation: "Thief Union", 
    postal: "Wuhan",
    email: "",
    phone: "",
    github: "",
    ),
    (name: "Rui Gao(高睿)", 
    affiliation: "", 
    postal: "Wuhan",
    email: "",
    phone: "",
    github: "",
    ),
    
  ),
  abstract: [我们经常会使用自然数的等幂求和问题:$display(sum_(i=1)^n i^z=1^z + 2^z + ... + n^z)$ 我们将讨论使用形式幂级数:$G(attach(a,br:n),x) = display(sum_(i=1)^n attach(a,br:i) x^i)$来取得形式解
  首先我们从形式幂级数的闭合表示出发 例如几何级数$display(sum_(i=1)^n x^i=x^1 + x^2 + ... + x^n)=frac(x^n-1,x-1)x$ 通过形式幂级数的微分与求和的关系得到求和的闭合表示
  我们会讨论形式幂级数的闭合表示的可行性
  我们会推广到n次幂的通项
],
)
#figure(
  image("profile.jpg", width: 20%),
  caption: "DonjuanPlatinum"
)
= 求和
== 二次幂求和与生成函数
首先我们来研究对于二次幂的自然数求和 $ display(sum_(i=1)^n i^2=1^2 + 2^2 + ... + n^2) $

我们不妨构造生成幂函数 $ cal(F)(x) = display(sum_(i=1)^n i x^i) = 1 x^1 + 2 x^2 + ... + n x^n$

我们不妨对$cal(F)(x)$进行求导 $ g(x) = frac(diff cal(F)(x),diff x) = display(sum_(i=1)^n i^2 x^(i-1)) = 1^2 x^0 + 2^2 x^1 + ... + n^2 x^(n-1) $

我们很容易的注意到 当 x = 1时, g(1)的函数值便是我们需要的形式解.

于是我们开始考虑$cal(F)(x)$的形式解
=== 生成函数的形式解
对于$cal(F)(x)$ 我们有 $ cal(F)(x) = display(sum_(i=1)^n i x^i) = 1 x^1 + 2 x^2 + ... + n x^n $ 

注意到i是等差级数 而$x^i$是几何级数

我们不妨对$cal(F)(x)$乘上几何级数的公比 有

$ x cal(F)(x) = display(sum_(i=1)^n i x^(i+1)) = 1 x^2 + 2 x^3 + ... + (n-1) x^n + n x^(n+1) $ 

我们将上面两式相减
$
 cal(F)(x) = display(sum_(i=1)^n i x^i) = 1 x^1 + &2 x^2 + 3 x^3 + ... + n x^n \
 x cal(F)(x) = display(sum_(i=1)^n i x^(i+1)) = &1 x^2 + 2 x^3 + ... + (n-1) x^n + n x^(n+1)
 
$
我们非常容易地得出
$
(1-x) cal(F)(x) = display(sum_(i=1)^n i x^(i+1)) = 1 x^1 + 1 x^2 + ... + 1 x^n - n x^(n+1)
$

注意到: 此时的函数的左部分满足几何级数形式
我们使用几何级数求和
$
display(sum_(i=0)^x a^i) = frac(a^(x+1) - 1,a -1)
$

我们得到
$
(1-x) cal(F)(x) = frac(x^n -1,x-1) x - n x^ (n+1) \

cal(F)(x) = frac(n x^(n+2) - (n+1)x^(n+1) + x,(x-1)^2) *
$

至此 我们获得了此生成函数的形式解
=== 由形式解到导数
我们对 \* 式求导函数
$
g(x) = frac(diff cal(F)(x),diff x)
$
我们容易的得到
$
g(x) = frac(n^2 x^(n+2) - (2 n^2 + 2 n - 1) x^(n+1) + (n+1) ^2 x^n -x -1,(x-1)^3)
$
=== 由导数到幂求和
我们已知g(1)是 $ display(sum_(i=1)^n i^2=1^2 + 2^2 + ... + n^2) $

但是我们注意到 当x = 1时 $(x-1)^3$ 是无意义的 于是我们考虑取极限
$ lim_(x-> 1) g(x) $

==== 极限
我们不妨令$ attach(phi,br:1)(x) = n^2 x^(n+2) - (2 n^2 + 2 n - 1) x^(n+1) + (n+1) ^2 x^n -x -1 \
attach(Phi,br:1)(x) = (x-1)^3
$
于是我们转而即求
$
lim_(x->1) frac(attach(phi,br:1)(x),attach(Phi,br:1)(x))
$
我们很容易地注意到$attach(phi,br:1)(1) = attach(Phi,br:1)(1) = 0$

$ because attach(phi,br:1)(x),attach(Phi,br:1)(x)$ 在以 $x = c$ 为端点的开区间可微, $lim_(x->1)attach(Phi,br:1)'(x) != 0,attach(phi,br:1)(1) = attach(Phi,br:1)(1) = 0 $
由L'Hôpital's定理
$
therefore lim_(x->1) frac(attach(phi,br:1)(x),attach(Phi,br:1)(x)) = lim_(x->1) frac(attach(phi,br:1)'(x),attach(Phi,br:1)'(x))
$

$ attach(phi,br:2)(x) = attach(phi,br:1)'(x) = (n+2) n^2 x^(n+1) - (n+1)(2n^2+2n-1)x^n +n (n+1)^2 x^(n-1) - 1 $
$ attach(Phi,br:2)(x) = 3(x-1)^2 $
我们注意到$lim_(x->1)attach(Phi,br:2)'(x) != 0,attach(phi,br:2)(1) = attach(Phi,br:2)(1) = 0 $
于是乎$ lim_(x->1) frac(attach(phi,br:2)(x),attach(Phi,br:2)(x)) =lim_(x->1) frac(attach(phi,br:3)(x),attach(Phi,br:3)(x)) $
$ attach(phi,br:3)(x) = (n+1)(n+2)n^2 x^n - n(n+1)(2n^2 + 2n -1) x^(n-1) + (n-1)n(n+1)^2 x^(n-2) $
$ attach(Phi,br:3)(x) = 6(x-1) $
注意到$lim_(x->1)attach(Phi,br:3)'(x) != 0,attach(phi,br:3)(1) = attach(Phi,br:3)(1) = 0 $
于是乎$ lim_(x->1) frac(attach(phi,br:3)(x),attach(Phi,br:3)(x)) =lim_(x->1) frac(attach(phi,br:4)(x),attach(Phi,br:4)(x)) $
$ attach(phi,br:4)(x) = (n+1)(n+2)n^3 x^(n-1) - (n-1)n(n+1)(2n^2+2n-1)x^(n-2) + (n-2)(n-1)n(n+1)^2 x^(n-3) $
$ attach(Phi,br:4)(x) = 6 $

即
$
g(x) = lim_(x->1) frac(attach(phi,br:4)(x),attach(Phi,br:4)(x)) = lim_(x->1) frac((n+1)(n+2)n^3 x^(n-1) - (n-1)n(n+1)(2n^2+2n-1)x^(n-2) + (n-2)(n-1)n(n+1)^2 x^(n-3),6) \
= frac(n(n+1)(2n+1),6)
$

于是乎 我们得出了形式解
$
 display(sum_(i=1)^n i^2=1^2 + 2^2 + ... + n^2) = frac(n(n+1)(2n+1),6)
$

== 三次幂求和
我们刚才讨论了二次幂的情况 那么生成函数的方法是否适用于任意正整数次数呢? 我们不妨先考察三次幂

 $ display(sum_(i=1)^n i^3=1^3 + 2^3 + ... + n^3) $

我们不妨构造生成幂函数 $ cal(F)(x) = display(sum_(i=1)^n i^2 x^i) = 1^2 x^1 + 2^2 x^2 + ... + n^2 x^n$

我们不妨对$cal(F)(x)$进行求导 $ g(x) = frac(diff cal(F)(x),diff x) = display(sum_(i=1)^n i^3 x^(i-1)) = 1^3 x^0 + 2^3 x^1 + ... + n^3 x^(n-1) $

我们很容易的注意到 当 x = 1时, g(1)的函数值便是我们需要的形式解.
=== 生成函数的形式解
对于 $ cal(F)(x) = display(sum_(i=1)^n i^2 x^i) = 1^2 x^1 + 2^2 x^2 + ... + n^2 x^n$
我们先乘几何级数的公比 有
$ x cal(F)(x) = display(sum_(i=1)^n i^2 x^(i+1)) = 1^2 x^2 + 2^2 x^3 + ... + (n-1)^2 x^n + n^2 x^(n+1) $

我们将上面两式相减
$
 cal(F)(x) = display(sum_(i=1)^n i^2 x^i) = 1^2 x^1 + &2^2 x^2 + ... + n^2 x^n \
 x cal(F)(x) = display(sum_(i=1)^n i^2 x^(i+1)) = &1^2 x^2 + 2^2 x^3 + ... + (n-1)^2 x^n + n^2 x^(n+1)
 
$

我们非常容易地得出
$
(1-x) cal(F)(x) = display(sum_(i=1)^n i x^(i+1)) = x + 3x^2 + 5 x^3 + 7 x^4 + ... + (2n - 1) x^n - n^2 x^(n+1)

$


我们不妨再乘几何级数的公比 有
$
x (1-x) cal(F)(x) = display(sum_(i=1)^n i x^(i+2)) = x^2 + 3x^3 + 5 x^4 + 7 x^5 +... + (2n - 1) x^(n+1) - n^2 x^(n+2)
$

$
cal(F)(x) = frac(x+x^2-(n+1)^2 x^n + (2 n^2 + 2n -1) x^(n+2) - n^2 x^(n+3),(1 - x)^3)
$
我们重复地使用L'Hôpital's定理 得到
$
cal(F)'(1) = frac(n^2 (n+1)^2,4)
$

=== 使用差分验证闭合形式的可行性
实际上 我们仅需证明 经过有限次差分后 得到的差分为常数

==== 二次幂
我们来考察上述的幂级数
#align(center)[
  #grid(
    columns: (2em, 2em, 2em, 2em, 2em,2em,2em),
    column-gutter: 0.5em,
    row-gutter: 0.3em,
    align: center,
    [$1^2$], [$2^2$], [$3^2$], [$4^2$], [$5^2$],[..],[$n^2$],
  )
]

一阶差分
$Delta f(x)$ = 3 5 7 9 ..

二阶差分
$Delta^2 f(x)$ = 2 2 2 ..

显然地 二阶差分是常数
==== 三次幂
我们来考察上述的幂级数
#align(center)[
  #grid(
    columns: (2em, 2em, 2em, 2em, 2em,2em,2em),
    column-gutter: 0.5em,
    row-gutter: 0.3em,
    align: center,
    [$1^3$], [$2^3$], [$3^3$], [$4^3$], [$5^3$],[..],[$n^3$],
  )
]

一阶差分
$Delta^2 f(x)$ = 7 19 37 61 ..

二阶差分
$Delta^3 f(x)$ = 12 18 24 ..

三阶差分
$Delta^4 f(x)$ = 6 6 ..

显然地 三阶差分是常数
==== k次幂
#align(center)[
  #grid(
    columns: (2em, 2em, 2em, 2em, 2em,2em,2em),
    column-gutter: 0.5em,
    row-gutter: 0.3em,
    align: center,
    [$1^k$], [$2^k$], [$3^k$], [$4^k$], [$5^k$],[..],[$n^k$],
  )
]

我们注意到 $Delta^k f(x) = k!$

证明: 我们使用数学归纳法

当k=1时 显然地成立

假设$Delta^k f(x) = k!$

则
$Delta^(k+1) f(x) = Delta^k f(x+1) - Delta^k f(x)  = Delta^k (f(x+1) - f(x)) = Delta^k ((x+1)^(K+1) - x^(k+1))$

展开有
$
(x+1)^(k+1) = display(sum_(i=1)^(k+1) vec(k+1,i) x^i)
$

则
$
Delta^(k+1) f(x) = &Delta^k (display(sum_(i=1)^(k+1) vec(k+1,i) x^i) - x^(k+1)) \ 
	    	 = &Delta^k (display(sum_(i=1)^(k) vec(k+1,i) x^i) ) \
		 = &display(sum_(i=1)^(k) vec(k+1,i) Delta^k x^i)
		 
$
其中
$
Delta^k x^i = k!
$
故
$
Delta^(k+1) f(x) = (k+1)!
$
至此便证明了差分对于闭合形式的可行性
== 解析延拓
我们开始研究闭合解
我们不妨使用第二类Stirling数展开求和
$
i^k = display(sum_(m=0)^(k) S(k,m) m! vec(i,m)  )
$
则
$
display(sum_(i=0)^(n) i^k x^i ) = display(sum_(m=0)^k S(k,m)m! display(sum_(i=0)^n vec(i,m) x^i))
$
则
$
display(sum_(i=0)^(n) i^k x^i ) = display(sum_(m=0)^(k) S(k,m) m! vec(i,m)  ) display(sum_(i=0)^(n) i^k x^i ) = display(sum_(m=0)^k S(k,m)m! display(sum_(i=0)^n vec(i,m) x^i))
$
那么由组合数生成函数公式有
$
display(sum_(i=0)^(n) i^k x^i ) = display(sum_(m=0)^k S(k,m)m! (frac(x^m,(1-x)^(m+1)) - x^(n+1) display(sum_(j=0)^m vec(n+1,j) frac(x^(m-j),(1-x)^(m-j+1)))))
$
我们求导得
$
frac(diff ,diff x) (display(sum_(i=0)^(n) i^k x^i )) = \
display(sum_(m=0)^k S(k,m) m!(frac(x^(m-1) (m+x),(1-x)^(m+2)) - (n+1) x^n display(sum_(j=0)^m vec(n+1,j) frac(x^(m-j),(1-x)^(m-j+1)) - x^(n+1) display(sum_(j=0)^m vec(n+1,j) frac(x^(m-j-1) (m-j+x) , (1-x)^(m-j+2))))))
$

我们发现 我们会连续地使用k+1次L'Hôpital's定理
则有
$
lim_(x->1) frac(diff ,diff x) (display(sum_(i=0)^(n) i^k x^i )) = display(sum_(i=0)^(n) i^k  ) = frac(B_(k+1) (n+1) - B_(k+1) (0),k+1)
$


// Bibliography section

