test_that("RemoveSeasonal returns group means and anomalies", {
  t_mmdd <- rep(c(101, 102, 201), each = 3)
  mu <- c(1, 5, -2)
  y <- rep(mu, each = 3) + c(1, -2, 1, 0, 4, -4, 2, 2, -4)

  res <- RemoveSeasonal(y, t_mmdd)

  expect_equal(res$mu, mu)
  expect_equal(res$anomaly, y - rep(mu, each = 3))
  expect_equal(as.numeric(tapply(res$anomaly, t_mmdd, mean)), rep(0, 3), tolerance = 1e-12)
})

test_that("RemoveSeasonal sorts groups and handles missing observations", {
  t_mmdd <- c(201, 101, 201, 101)
  y <- c(4, 1, NA, 3)

  res <- RemoveSeasonal(y, t_mmdd)

  expect_equal(res$mu, c(2, 4))
  expect_equal(res$anomaly, c(0, -1, NA, 1))
})

test_that("RemoveSeasonal validates its input", {
  expect_error(RemoveSeasonal(1:3, 1:2), "same length", fixed = TRUE)
  expect_error(RemoveSeasonal(1:3, c(101, NA, 102)), "must not contain NA", fixed = TRUE)
})

test_that("LS_OneBreak recovers a single break", {
  set.seed(1)
  n <- 100
  X <- seq_len(n)
  Y <- 10 + 0.5 * X + c(rep(0, 60), rep(5, 40)) + rnorm(n, sd = 0.1)

  fit <- LS_OneBreak(Y, X, 60)
  m <- lm(Y ~ X + I(seq_len(n) > 60))

  expect_equal(unname(fit$coef), unname(coef(m)), tolerance = 1e-8)
  expect_equal(fit$fitted, unname(fitted(m)), tolerance = 1e-8)
  expect_equal(fit$resi, unname(residuals(m)), tolerance = 1e-8)
  expect_equal(fit$fitted + fit$resi, Y, tolerance = 1e-10)
  expect_equal(sum(fit$resi^2), fit$SSE, tolerance = 1e-10)
})

test_that("LS_OneBreak with Ic = NA is ordinary linear regression", {
  X <- seq_len(30)
  Y <- 2 + 0.3 * X
  fit <- LS_OneBreak(Y, X, NA)

  expect_equal(length(fit$coef), 2L)
  expect_equal(unname(fit$coef), unname(coef(lm(Y ~ X))), tolerance = 1e-10)
})

test_that("LS_OneBreak can return only SSE", {
  X <- seq_len(30)
  Y <- 2 + 0.3 * X + c(rep(0, 20), rep(1, 10))
  fit <- LS_OneBreak(Y, X, 20)
  sse <- LS_OneBreak(Y, X, 20, only.SSE = TRUE)

  expect_equal(sse, list(SSE = fit$SSE))
})

test_that("LS_OneBreak validates its input", {
  X <- seq_len(30)
  Y <- 2 + 0.3 * X

  expect_error(LS_OneBreak(Y, X[-1], 10), "same length", fixed = TRUE)
  expect_error(LS_OneBreak(Y, X, c(10, 20)), "single value", fixed = TRUE)
  expect_error(LS_OneBreak(Y, X, 0), "Ic", fixed = TRUE)
  expect_error(LS_OneBreak(Y, X, 30), "Ic", fixed = TRUE)
})

test_that("LS_MultiBreaks matches a factor-coded regression", {
  set.seed(2)
  n <- 100
  X <- seq_len(n)
  segment <- factor(rep(1:3, c(30, 40, 30)))
  Y <- 10 + 0.5 * X + c(rep(0, 30), rep(4, 40), rep(-3, 30)) + rnorm(n, sd = 0.1)

  fit <- LS_MultiBreaks(Y, X, c(30, 70, 100))
  m <- lm(Y ~ I(X - mean(X)) + segment)

  expect_equal(length(fit$coef), 4L)
  expect_equal(unname(fit$coef), unname(coef(m)), tolerance = 1e-8)
  expect_equal(fit$fitted + fit$resi, Y, tolerance = 1e-10)
  expect_equal(sum(fit$resi^2), fit$SSE, tolerance = 1e-10)
})

test_that("LS_MultiBreaks agrees with LS_OneBreak for one break", {
  set.seed(3)
  X <- seq_len(80)
  Y <- 5 + 0.2 * X + c(rep(0, 50), rep(2, 30)) + rnorm(80, sd = 0.05)

  multi <- LS_MultiBreaks(Y, X, c(50, 80))
  single <- LS_OneBreak(Y, X, 50)

  expect_equal(multi$fitted, single$fitted, tolerance = 1e-10)
  expect_equal(multi$SSE, single$SSE, tolerance = 1e-10)
})

test_that("LS_MultiBreaks validates its input", {
  X <- seq_len(30)
  Y <- 2 + 0.3 * X

  expect_error(LS_MultiBreaks(Y, X[-1], c(10, 30)), "same length", fixed = TRUE)
  expect_error(LS_MultiBreaks(Y, X, 10), "at least two", fixed = TRUE)
  expect_error(LS_MultiBreaks(Y, X, c(30, 10)), "strictly increasing", fixed = TRUE)
  expect_error(LS_MultiBreaks(Y, X, c(10, 20)), "last value", fixed = TRUE)
})

test_that("lm_solve validates dimensions", {
  expect_error(lm_solve(matrix(1:6, nrow = 3), 1:4), "same number of rows", fixed = TRUE)
})
