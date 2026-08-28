# LeetGPU
## Vector Addition
向量加法.

```
Write a GPU program that performs element-wise addition of two vectors containing 32-bit floating point numbers. The program should take two input vectors of equal length and produce a single output vector containing their sum.

Implementation Requirements
External libraries are not permitted
The solve function signature must remain unchanged
The final result must be stored in vector C
Example 1:
Input:  A = [1.0, 2.0, 3.0, 4.0]
        B = [5.0, 6.0, 7.0, 8.0]
Output: C = [6.0, 8.0, 10.0, 12.0]
Example 2:
Input:  A = [1.5, 1.5, 1.5]
        B = [2.3, 2.3, 2.3]
Output: C = [3.8, 3.8, 3.8]
Constraints
Input vectors A and B have identical lengths
1 ≤ N ≤ 100,000,000
Performance is measured with N = 25,000,000
```

### 题解
这个向量加法 直接启动相应个threads去加即可 O(1)时间可以完成.

比如 1 * n + 1 * n, 启动n个threads即可.


```c++
#include <cuda_runtime.h>

__global__ void vector_add(const float* A, const float* B, float* C, int N) {
  // 计算当前thread在向量加法的编号
  // idx = block_id * block_dim + thread_id
  int i = blockIdx.x * blockDim.x + threadIdx.x;

  // 计算步长
  int stride = blockDim.x * gridDim.x;

  for (;i < N; i += stride) {
    C[i] = A[i] + B[i];
  }
}

// A, B, C are device pointers (i.e. pointers to memory on the GPU)
extern "C" void solve(const float* A, const float* B, float* C, int N) {
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    vector_add<<<blocksPerGrid, threadsPerBlock>>>(A, B, C, N);
    cudaDeviceSynchronize();
}
```
## Matrix Multiplication
```
Matrix Multiplication
Easy
Write a program that multiplies two matrices of 32-bit floating point numbers on a GPU. Given matrix 
 of dimensions 
 and matrix 
 of dimensions 
, compute the product matrix 
, which will have dimensions 
. All matrices are stored in row-major format.

Implementation Requirements
Use only native features (external libraries are not permitted)
The solve function signature must remain unchanged
The final result must be stored in matrix C
Example 1:
Input:
Matrix 
 (
):
 
Matrix 
 (
):
 
Output:
Matrix 
 (
):
 

Example 2:
Input:
Matrix 
 (
):
 
Matrix 
 (
):
 
Output:
Matrix 
 (
):
 

Constraints
1 ≤ M, N, K ≤ 8192
Performance is measured with M = 8192, N = 6144, K = 4096
```
### 题解
A矩阵是M * N, B矩阵是 N * K. 我们需要计算矩阵乘法.

朴素的方法是用矩阵乘积公式.
