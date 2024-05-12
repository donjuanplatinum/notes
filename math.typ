= 数学
+ 公式
  - #link(<拉马努金>)[拉马努金]
    + #link(<pi>)[$pi$]
  - #link(<欧拉>)[欧拉]
    + #link(<欧拉公式>)[欧拉公式]

  - #link(<傅立叶>)[傅立叶]
    + #link(<DFT>)[离散傅立叶变换(DFT)]
    + #link(<FT>)[傅立叶变换(FT)]
+ 定理
  - #link(<费马>)[费马]
    + #link(<费马大定理>)[费马大定理]

=== 拉马努金 #label("拉马努金")
==== $pi$ #label("pi")
$1/pi = (2sqrt(2)) /9801 display(sum_(k=0)^infinity) ((4k)!(1103+26390k)) / ((K!)^4 396^(4k))$

=== 欧拉 #label("欧拉")
==== 欧拉公式 #label("欧拉公式")
$e^(i x) = cos x + i sin x $\ 

特别的 当$x = pi$时 于是出现了上帝公式\ 

$e^(i pi) = -1$

=== 费马 #label("费马")
==== 费马大定理 #label("费马大定理")
方程 $ x^n + y^n = z^n $ 当$n gt.eq 3$时 方程不存在整数解

=== 傅立叶 #label("傅立叶")
==== 傅立叶变换(FT) #label("FT")
f(t)是t的 *周期函数* , 若t满足狄利克雷条件 则下式成立 称为积分运算f(t)的傅立叶变换\
其中 $F(omega)$ 叫做f(t)的象函数 f(t) 叫做 $F(omega)$ 的象原函数 $F(omega)$是f(t)的象 \
$F(omega) = cal(F)[f(t)] = display(attach(integral ,t: infinity,b: - infinity))f(t)e^(- i omega t) d t$

==== 傅立叶逆变换
$f(t) = cal(F) ^ (-1) [F(omega)] = frac(1,2 pi) display(attach(integral,t: infinity, b: - infinity)) F(omega) e ^ (i w t) d omega$

$accent(f,hat)(k) = <f,attach(E,br:k)>$
==== 离散傅立叶变换(DFT) #label("DFT")

