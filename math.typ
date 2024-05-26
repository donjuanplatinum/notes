#show heading: set text(red)
#show link: set text(blue)
#show enum: set text(green)
#show strong: set text(yellow)
= 数学
+ 公式
  - #link(<拉马努金>)[拉马努金]
    + #link(<pi>)[$pi$]
  - #link(<欧拉>)[欧拉]
    + #link(<欧拉公式>)[欧拉公式]
    + #link(<欧拉第二积分>)[欧拉第二积分]
  - #link(<傅立叶>)[傅立叶]
    + #link(<DFT>)[离散傅立叶变换(DFT)]
    + #link(<FT>)[傅立叶变换(FT)]
  - #link(<拉普拉斯>)[拉普拉斯]
    + #link(<拉普拉斯变换>)[拉普拉斯变换]

+ 定理
  - #link(<费马>)[费马]
    + #link(<费马大定理>)[费马大定理]

=== 拉马努金 #label("拉马努金")
==== $pi$ #label("pi")
$ 1/pi = (2sqrt(2)) /9801 display(sum_(k=0)^infinity) ((4k)!(1103+26390k)) / ((K!)^4 396^(4k)) $

=== 欧拉 #label("欧拉")
==== 欧拉公式 #label("欧拉公式")
$ e^(i x) = cos x + i sin x $\ 

特别的 当$x = pi$时 于是出现了上帝公式\ 

$ e^(i pi) = -1 $


==== 欧拉第二积分 #label("欧拉第二积分")
*伽玛函数* 作为阶乘函数的延拓 是定义在复数范围内的压纯函数 \
在 *实数域* 上的伽玛函数: \
$ Gamma(x) = attach(integral,t: +infinity,b: 0)t ^ (x-1) e ^ (-t) d t (x>0) $
在 *复数域* 上的伽玛函数: \
$ Gamma(z) = attach(integral,t: +infinity,b: 0) t ^ (z-1) e ^ (-1) d t $

=== 费马 #label("费马")
==== 费马大定理 #label("费马大定理")
方程 $ x^n + y^n = z^n $ 当$n gt.eq 3$时 方程不存在整数解

=== 傅立叶 #label("傅立叶")
==== 傅立叶变换(FT) #label("FT")

f(t)是t的 *周期函数* , 若t满足狄利克雷条件 则下式成立 称为积分运算f(t)的傅立叶变换\

其中 $F(omega)$ 叫做f(t)的象函数 f(t) 叫做 $F(omega)$ 的象原函数 $F(omega)$是f(t)的象 \



$ F(omega) = cal(F)[f(t)] = display(attach(integral ,t: infinity,b: - infinity))f(t)e^(- i omega t) d t $

==== 傅立叶逆变换
$ f(t) = cal(F) ^ (-1) [F(omega)] = frac(1,2 pi) display(attach(integral,t: infinity, b: - infinity)) F(omega) e ^ (i w t) d omega $

==== 离散傅立叶变换(DFT) #label("DFT")


=== 拉普拉斯 #label("拉普拉斯")
==== 拉普拉斯变换 #label("拉普拉斯变换")
在一个区间$[0,infinity)$的函数$f(t)$ 他的拉普拉斯变换式$F(s)$定义为
$ L[f(t)] = F(s) = attach(integral,t: infinity,b: 0) f(t) e ^ (-s t) d t $ \
其中 F(s) 为复变量s的函数 是把一个时间域的函数f(t) 变换到复频域的复变函数 \
$e ^(s t)$为收敛因子 \
$s = sigma + j omega$ 为复数形式的频率
