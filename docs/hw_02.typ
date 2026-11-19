#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "水文气象学", header: "")

= 1 函数说明

本作业以 `rpkg.template` 为模板建立 R 包，将 `rpkgs/RHtests` 中的季节调整与分段线性回归
函数整理为可复用、可测试的实现：

- `RemoveSeasonal()`：按日历标签扣除季节循环；
- `LS_OneBreak()`：单断点、同斜率分段线性回归；
- `LS_MultiBreaks()`：多断点、同斜率分段线性回归；
- `lm_solve()`：用 QR 分解求解最小二乘，是前两者的计算核心。

= 2 去季节

设观测序列为 $y_t$，对应的月日标签为 $m_t$（`MMDD`，例如 101 表示 1 月 1 日）。
记 $n_m$ 为标签等于 $m$ 的样本数，季节均值与去季节序列定义为

$
  mu_m = 1/n_m sum_(t : m_t = m) y_t, quad
  a_t = y_t - mu_(m_t)
$

`RemoveSeasonal(y, t_mmdd)` 返回两个向量：按 `t_mmdd` 升序排列的 `mu`，以及与之对应的
`anomaly`。缺测 `NA` 在计算均值时被忽略，并原样保留在去季节序列中。

```r
set.seed(1)
t_mmdd <- rep(101:112, each = 5)
y <- 10 + 5 * sin(2 * pi * (t_mmdd %% 100) / 12) + rnorm(length(t_mmdd))
res <- RemoveSeasonal(y, t_mmdd)

op <- par(mfrow = c(2, 1), mar = c(3, 4, 1, 1))
plot(y, type = "l", xlab = "t", ylab = "y")
lines(rep(res$mu, each = 5), col = 2, lwd = 2)
legend("topright", c("观测", "季节均值"), col = c(1, 2), lty = 1, bty = "n")
plot(res$anomaly, type = "l", xlab = "t", ylab = "anomaly")
abline(h = 0, lty = 2)
par(op)
```

#figure(image("figure/fig-seasonal-1.svg", width: 80%), caption: [模拟观测、季节均值与去季节序列])



#figure(
three-line-table[
  | *月日* | *季节均值* |
  | :-- | --: |
  | 101 | 12.63 |
  | 102 | 14.47 |
  | 103 | 15.04 |
  | 104 | 14.79 |
  | 105 | 12.58 |
  | 106 | 9.65 |
  | 107 | 7.54 |
  | 108 | 5.87 |
  | 109 | 5.03 |
  | 110 | 5.91 |
  | 111 | 7.59 |
  | 112 | 10.20 |
],
  caption: [各月日的季节均值],
)


= 3 单断点回归

单断点模型为

$
  y_t = beta_0 + beta_1 x_t + delta 1(t > I_c) + epsilon_t
$

其中 $I_c$ 为断点位置，`LS_OneBreak(Y, X, Ic)` 用设计矩阵
$[1, x_t, 1(t > I_c)]$ 求解。当 `Ic = NA` 时退化为普通线性回归。

```r
set.seed(2)
n <- 100
X <- seq_len(n)
Y <- 10 + 0.5 * X + c(rep(0, 60), rep(5, 40)) + rnorm(n, sd = 0.1)
fit <- LS_OneBreak(Y, X, 60)

plot(X, Y, pch = 16, cex = 0.5, xlab = "x", ylab = "y")
lines(X, fit$fitted, col = 2, lwd = 2)
abline(v = 60, lty = 2)
```

#figure(image("figure/fig-onebreak-1.svg", width: 80%), caption: [单断点分段线性回归拟合])



#figure(
three-line-table[
  | *系数* | *估计值* |
  | :-- | --: |
  | 截距 | 10.017 |
  | 斜率 | 0.500 |
  | 断点跳跃 | 4.980 |
],
  caption: [单断点模型系数],
)


= 4 多断点回归

多断点模型为

$
  y_t = beta_0 + beta_1 (x_t - overline(x)) + sum_(k = 2)^K delta_k
  1(I_(k - 1) < t <= I_k) + epsilon_t
$

其中 $I_k$ 为第 $k$ 段末尾的位置，即 `Ips[k]`，且 `Ips` 末位必须等于序列长度。
每个示性变量以第一段为参照，因此第 $k$ 段的截距为 $beta_0 + delta_k$。
`LS_MultiBreaks(Y, X, Ips)` 与因子编码的回归 `lm(Y ~ X + factor(segment))` 等价。

#figure(
three-line-table[
  | *模型* | *SSE* |
  | :-- | --: |
  | 无断点 | 744.413 |
  | 单断点 | 265.708 |
  | 双断点 | 0.899 |
],
  caption: [不同断点数下的残差平方和],
)


= 5 测试

`tests/testthat/test-zuoye.R` 覆盖以下内容：

- 去季节结果与分组均值一致，`NA` 处理正确；
- 单断点与多断点模型的系数、拟合值、残差与 `lm()` 一致；
- `fitted + resi = Y` 与 `sum(resi^2) = SSE` 的恒等式；
- `Ic = NA` 时退化为普通线性回归；
- 非法输入均给出明确报错。

在包根目录运行 `testthat::test_local()` 即可复现。
