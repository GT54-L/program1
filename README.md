# Seasonal adjustment and piecewise linear regression

<!-- badges: start -->
[![R-CMD-check](https://github.com/GT54-L/program1/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/GT54-L/program1/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/GT54-L/program1/branch/master/graph/badge.svg)](https://app.codecov.io/gh/GT54-L/program1)
<!-- badges: end -->

`rpkg.template` 是一个练习包：从 `rpkgs/RHtests` 整理季节调整与分段线性回归函数，
并补齐 roxygen 文档、`testthat` 测试与 typst 报告。

## 函数

| 函数 | 说明 |
| --- | --- |
| `RemoveSeasonal(y, t_mmdd)` | 按 `MMDD` 分组计算季节均值并返回去季节序列 |
| `LS_OneBreak(Y, X, Ic)` | 单断点、同斜率分段线性回归 |
| `LS_MultiBreaks(Y, X, Ips)` | 多断点、同斜率分段线性回归 |
| `lm_solve(design, response)` | 用 QR 分解求解最小二乘（内部函数） |

## Installation

```r
remotes::install_github("GT54-L/program1")
```

## Example

```r
library(rpkg.template)

t_mmdd <- rep(101:112, each = 5)
y <- 10 + 5 * sin(2 * pi * (t_mmdd %% 100) / 12) + rnorm(length(t_mmdd))
res <- RemoveSeasonal(y, t_mmdd)

X <- seq_len(100)
Y <- 10 + 0.5 * X + c(rep(0, 60), rep(5, 40)) + rnorm(100, sd = 0.1)
LS_OneBreak(Y, X, 60)$coef
```

## Documentation and tests

- 文档源码：`docs/hw_02.Rtyp`，生成 `docs/hw_02.pdf`
- 测试：`tests/testthat/test-zuoye.R`

```r
testthat::test_local()
```
