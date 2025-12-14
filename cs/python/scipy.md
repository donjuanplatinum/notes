# Scipy
也是一个数学库 与numpy一起用 包含了很多数学算法 FFT 插值 积分 线代 微分方程等

## FFT
快速傅立叶变换

i代表逆变换

- `fft()/ifft()`: 一维快速傅立叶变换
- `fft2()/ifft2()`: 二维快速傅立叶变换
- `fftn()/ifftn()`: n维快速傅立叶变换
- `dct()/idct()`: 离散余弦变换
- `dst()/idst()`: 离散正弦变换

## differentiate
有限的差分和微分

- `derivative()`: 有限差分法近似计算一阶导
- `jacobian()`: 雅可比矩阵
- `hessian()`: 海森矩阵

## signal
信号处理

- `convolve(array1,array2)`: 卷积
- `correlate(array1,array2)`: 互相关
- `fftconvolve(array1,array2)`: 使用FFT卷积
## interpolate
插值
