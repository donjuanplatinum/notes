# scikit-learn
深度学习库 基于matplotlib scipy和numpy

## gaussian_process
高斯过程是**非参数监督**学习方法 用于解决 **回归** 与 **概率分类** 的问题

优点
- 预测结果通过插值观测值得出
- 预测是概率性(高斯性的) 可以计算经验置信区间 并根据这些置信区间决定是否应该在感兴趣的某个区域重新拟合（在线拟合、自适应拟合）预测
- 可以指定不同的内核

缺点
- 在高维空间中，它们的效率会降低——尤其是在特征数量超过几十个的时候
### GaussianProcessRegressor
高斯过程回归GPR

```python
class GaussianProcessRegressor(MultiOutputMixin, RegressorMixin, BaseEstimator):
	def __init__(
        self,
        kernel=None,
        *,
        alpha=1e-10,
        optimizer="fmin_l_bfgs_b",
        n_restarts_optimizer=0,
        normalize_y=False,
        copy_X_train=True,
        n_targets=None,
        random_state=None,
    )
```

其中
- kernel： 代表核函数
- alpha: 噪声
- optimizer: LML的优化器 在训练时优化高斯过程的核的参数的
- n_restarts_optimizer: 此参数指定优化器应从随机选择的超参数起始点运行多少次 防止局部最优
