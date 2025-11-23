# Manim
数学动画制作

## 开始
启动新项目
```shell
manim init project manim-project --default
```

更改main.py
```python
from manim import *


class CreateCircle(Scene):
    def construct(self):
        circle = Circle()  
        circle.set_fill(PINK, opacity=0.5)  
        self.play(Create(circle))  
```
渲染
```shell
manim -pql main.py
```


## Scene
Manim的画布类


Manim的场景一般都需要继承这个类 所有的动画必须impl它的construct方法

```python
class MyScene(Scene):
	def construct(self):
		self.play(Write(Text("Hello World!")))
```


### 方法
- play: 播放动画
- pause: 暂停
- wait: 停止
## Mobject
可以显示的基础类 它的点的类型是numpy.ndarray

简单的形状 Circle Arrow Rectangle 都是Mobject

默认情况下 Mobject创建的地方都是屏幕中心 在构建时 可以使用移动的函数进行平移
### 方法
- add(Mobject): 添加子Mobject
- remove(Mobject): 删除子Mobject
- shift(vec): 按照指定向量平移

LEFT UP RIGHT DOWN是四个垂直方向的向量

```python
circle = Circle()
square = Square()
triangle = Triangle()

circle.shift(LEFT)
square.shift(UP)
triangle.shift(RIGHT)
```

- move_to(vec): 将中心移动Mobject到某个 Point3D 点。
- next_to(mobject,vec): 放在object旁边的vec方向
```python
circle = Circle()
square = Square()
triangle = Triangle()
		
circle.move_to(LEFT * 2)
square.next_to(circle, LEFT)
triangle.align_to(circle, LEFT)

self.add(circle, square, triangle)
self.wait(1)
```


- set_fill(color=None,opacity=none,family=True): 设置图形的填充颜色和不透明度

family=True时 子Mobject也会应用

- set_troke(color=None,width,opacity): 设置边框
## 对象
### Text
文本对象
### Do
点对象
### Circle
圆
### Square
正方形
### Rectangle
菱形
### Axes
坐标轴
```python
Axes(x_range,y_range,x_length,y_length)
```
## 变换函数
### Transform(m1,m2)
m1变形m2
### FadeIn(m)
淡入
### FadeOut(m)
淡出
### Rotate(m,angle)
就地旋转
### ScaleInPlace(m,factor)
就地缩放
### GrowFromCenter(m)
从中心长出来
### GrowArrow(m)
画箭头
### ShowCreation(m)
手绘


## 示例
### 泰勒展开
```python
import math
from manim import *

class DrawSin(Scene):
    def construct(self):
        # 创建坐标轴
        axes = Axes(
            x_range=[-10, 10, 1],   # x轴范围
            y_range=[-10, 10, 1],  # y轴范围
            x_length=8,
            y_length=8,
            tips=False,
        )
        plane = NumberPlane()
        self.play(Create(plane))

        sin_curve = axes.plot(lambda x: np.sin(x), color=BLUE)


        self.play(Create(axes))
        self.play(Write(sin_curve))
        self.wait(1)

        one = axes.plot(lambda x: x,color=PINK)
        self.play(Write(one))
        self.wait(0.5)

        two = axes.plot(lambda x: x - x**3 /6,color=PINK)
        self.play(ReplacementTransform(one,two))
        self.wait(0.5)

        three = axes.plot(lambda x: x - x**3 /6 + x**5/120,color=PINK)
        self.play(ReplacementTransform(two,three))
        self.wait(0.5)


```

### 贝叶斯优化
