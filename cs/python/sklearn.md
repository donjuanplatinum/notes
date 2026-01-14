# scikit-learn
深度学习库 基于matplotlib scipy和numpy

是很多模型的最佳实现
## 线性模型
线性模型基本有几个共同的参数

penalty: 用于指定正则化类型 `l1`,`l2`,`elasticnet` 分别为L1 L2 L1+L2正则

若后面加个CV代表交叉验证

- `LinearRegression`: 最小二乘线性回归
- `PassiveAggressiveClassifer`: 被动攻击分类器(废弃) 被封装进了SGDClassifier的learning_rate="pa1"或pa2
- `Ridge`: 岭回归 就是线性回归+L2正则
- `Lasso`: Lasso回归 就是线性回归+L1正则 用于估计稀疏系数c
- `LogisticRegression/LogisticRegressionCV`: 逻辑回归

- `Perceptron`: 线性感知分类器 使用梯度下降回归 是`SGDClassifier`的参数封装 使用的是perceptron感知机损失函数
- `SGDClassifier/SGDRegressor`: SGD训练的线性分类器/回归器
通过指定不同的损失函数来应用到不同的任务
| Loss          | 任务                  |
|---------------|-----------------------|
| hinge         | SVM                   |
| log           | 逻辑回归的对数损失    |
| perceptron    | 感知机                |
| squared_hinge | 平方后的hinge 用于SVM |
| huber         | huber损失             |
- `ElasticNet/`: L1+L2的线性回归

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
