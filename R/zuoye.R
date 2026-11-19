# 季节调整与分段线性回归 ------------------------------------------------
# 整理自 rpkgs/RHtests::R/Component.R

#' 去除季节循环
#'
#' 按 `t_mmdd` 分组计算季节均值，并从观测中扣除。
#'
#' @param y 观测序列。
#' @param t_mmdd 与 `y` 等长的月日标签（`MMDD` 整数）。月尺度最多 12 个取值，
#'   日尺度最多 366 个取值。
#'
#' @return 列表，含两个向量：
#' - `mu`: 按 `t_mmdd` 升序排列的季节均值；
#' - `anomaly`: 去季节序列，即 `y - mu`。
#'
#' @examples
#' t_mmdd <- rep(c(101, 102), each = 3)
#' y <- c(1, 2, 3, 10, 11, 12)
#' RemoveSeasonal(y, t_mmdd)
#' @export
RemoveSeasonal <- function(y, t_mmdd) {
  n <- length(y)
  if (length(t_mmdd) != n) {
    stop("`y` and `t_mmdd` must have the same length.", call. = FALSE)
  }
  if (anyNA(t_mmdd)) {
    stop("`t_mmdd` must not contain NA.", call. = FALSE)
  }

  inds <- sort(unique(t_mmdd))
  mu <- vapply(inds, function(i) mean(y[t_mmdd == i], na.rm = TRUE), numeric(1))
  list(mu = mu, anomaly = y - mu[match(t_mmdd, inds)])
}

#' 多断点分段线性回归
#'
#' 拟合斜率相同、截距不同的分段线性模型。第 `i` 个断点位于 `Ips[i]`，
#' 第 `i` 段覆盖位置 `(Ips[i - 1] + 1):Ips[i]`。
#'
#' @param Y 响应向量。
#' @param X 自变量向量（通常为时间）。
#' @param Ips 各段末尾的位置，严格递增，末位必须为 `length(Y)`。
#' @param ... 传给 [lm_solve()]。
#'
#' @return 见 [lm_solve()]：`coef`、`fitted`、`resi`、`SSE`。
#'
#' @examples
#' X <- seq_len(60)
#' Y <- 1 + 0.5 * X + c(rep(0, 40), rep(3, 20))
#' LS_MultiBreaks(Y, X, c(40, 60))$coef
#' @export
LS_MultiBreaks <- function(Y, X, Ips, ...) {
  n <- length(Y)
  if (length(X) != n) {
    stop("`X` and `Y` must have the same length.", call. = FALSE)
  }
  if (length(Ips) < 2L) {
    stop("`Ips` must contain at least two positions.", call. = FALSE)
  }
  if (is.unsorted(Ips, strictly = TRUE)) {
    stop("`Ips` must be strictly increasing.", call. = FALSE)
  }
  if (Ips[length(Ips)] != n) {
    stop("The last value of `Ips` must equal `length(Y)`.", call. = FALSE)
  }

  n_breaks <- length(Ips) - 1L
  design <- cbind(1, X - mean(X))
  for (i in seq_len(n_breaks)) {
    segment <- numeric(n)
    segment[(Ips[i] + 1L):Ips[i + 1L]] <- 1
    design <- cbind(design, segment)
  }
  lm_solve(design, Y, ...)
}

#' 单断点分段线性回归
#'
#' 拟合斜率相同、截距不同的单断点模型：`[1, Ic]` 与 `[Ic + 1, n]` 两段。
#'
#' @param Y 响应向量。
#' @param X 自变量向量。
#' @param Ic 断点位置。`NA` 表示无断点（普通线性回归）；
#'   否则必须位于 `[1, length(Y) - 1]`。
#' @param ... 传给 [lm_solve()]。
#'
#' @return 见 [lm_solve()]：`coef`、`fitted`、`resi`、`SSE`。
#'
#' @examples
#' X <- seq_len(60)
#' Y <- 1 + 0.5 * X + c(rep(0, 40), rep(3, 20))
#' LS_OneBreak(Y, X, 40)$coef
#' @export
LS_OneBreak <- function(Y, X, Ic, ...) {
  n <- length(Y)
  if (length(X) != n) {
    stop("`X` and `Y` must have the same length.", call. = FALSE)
  }
  if (length(Ic) != 1L) {
    stop("`Ic` must be a single value or `NA`.", call. = FALSE)
  }

  design <- cbind(1, X)
  if (!is.na(Ic)) {
    if (Ic < 1L || Ic >= n) {
      stop("`Ic` must be in `[1, length(Y) - 1]`.", call. = FALSE)
    }
    design <- cbind(design, c(rep(0, Ic), rep(1, n - Ic)))
  }
  lm_solve(design, Y, ...)
}

#' 最小二乘求解
#'
#' 用 QR 分解求解线性模型，是 [LS_OneBreak()] 与 [LS_MultiBreaks()] 的计算核心。
#'
#' @param design 设计矩阵。
#' @param response 响应向量。
#' @param only.SSE 若为 `TRUE`，只返回残差平方和，用于断点搜索。
#' @param ... 预留参数。
#'
#' @return 当 `only.SSE = FALSE` 时返回列表 `coef`、`fitted`、`resi`、`SSE`；
#'   否则返回 `list(SSE = ...)`。
#' @keywords internal
lm_solve <- function(design, response, only.SSE = FALSE, ...) {
  design <- as.matrix(design)
  response <- as.matrix(response)
  if (nrow(design) != nrow(response)) {
    stop("`design` and `response` must have the same number of rows.", call. = FALSE)
  }

  fit <- stats::.lm.fit(design, response)
  fitted <- drop(design %*% fit$coefficients)
  SSE <- sum(fit$residuals^2)

  if (only.SSE) {
    return(list(SSE = SSE))
  }
  list(
    coef = drop(fit$coefficients),
    fitted = fitted,
    resi = drop(fit$residuals),
    SSE = SSE
  )
}
