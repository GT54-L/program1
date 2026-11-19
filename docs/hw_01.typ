#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "水文气象学", header: "")

= 1 第一题

设随机变量 $X ~ N(0, 1)$，求 $P(X < 1.96)$。由行内代码算得 0.975。

= 2 第二题：绘图

```r
hist(rnorm(1e4), breaks = 40, main = "", xlab = "x")
```

#figure(image("figure/fig-hist-1.svg", width: 80%), caption: [标准正态随机数的直方图])



= 3 第三题：表格

#figure(
three-line-table[
  | *speed* | *dist* |
  | --: | --: |
  | 4 | 2 |
  | 4 | 10 |
  | 7 | 4 |
],
  caption: [cars 前 3 行],
)


= 4 第四题：回归

#figure(
three-line-table[
  | *term* | *est* |
  | --- | --- |
  | (Intercept) | -17.579 |
  | speed | 3.932 |
],
  caption: [dist 对 speed 的线性回归],
)

