#! /usr/bin/Rscript --no-init-file
# Dongdong Kong ----------------------------------------------------------------
# knitr -> typst 最小管线：一个 .Rtyp 文件同时装 typst 正文和 R 代码块。
#
#   source("scripts/typst.R")
#   render_typst("docs/hw_01.Rtyp")   # 生成同目录下 hw_01.typ 与 hw_01.pdf

`%||%` <- function(x, y) if (is.null(x)) y else x

## 1. knitr 钩子：把 markdown 语法换成 typst ------------------------------
# 代码块 / 输出：typst 与 markdown 共用 ``` 围栏，直接照搬
hook_source <- function(x, options) {
  if (isFALSE(options$echo)) return("")
  sprintf("```%s\n%s\n```\n\n", options$lang %||% "r", paste(x, collapse = "\n"))
}

hook_output <- function(x, options) {
  if (!length(x)) return("")
  sprintf("```\n%s\n```\n\n", paste(x, collapse = "\n"))
}

# 图形：markdown 的 ![](f.png) 在 typst 里无效，换成 #figure(image(...))
hook_plot <- function(x, options) {
  if (identical(options$fig.show, "hide")) return("")
  width <- as.character(options$out.width %||% "80%")
  if (grepl("^[0-9.]+$", width)) width <- paste0(width, "%")
  img <- sprintf('image("%s", width: %s)', x, width)
  cap <- options$fig.cap
  if (length(cap) && nzchar(cap[1])) {
    sprintf("#figure(%s, caption: [%s])\n\n", img, cap[1])
  } else {
    sprintf("#align(center)[#%s]\n\n", img)
  }
}

## 2. 表格：data.frame -> tablem 语法的三线表源码 -------------------------
# 模板里 #import ...: * 已带入 tablem / three-line-table，故直接输出管道表。
# 在代码块里配 `#| results: asis` 使用：cat(typst_table(df, caption = "…"))
typst_table <- function(df, caption = NULL, digits = 3, align = NULL, escape = TRUE) {
  mark <- c("\\", "#", "$", "@", "[", "]", "*", "_", "`", "<", ">", "~")
  esc <- function(x) {
    vapply(strsplit(x, ""), function(ch) {
      paste0(ifelse(ch %in% mark, "\\", ""), ch, collapse = "")
    }, character(1), USE.NAMES = FALSE)
  }
  chr <- function(x) {
    x <- if (is.numeric(x)) format(round(x, digits), trim = TRUE) else as.character(x)
    x[is.na(x)] <- ""
    if (escape) esc(x) else x
  }
  cols <- lapply(df, chr)
  row <- function(x) paste0("| ", paste(x, collapse = " | "), " |")
  sep <- c(auto = "---", l = ":--", c = ":-:", r = "--:")
  sep <- sep[rep(if (is.null(align)) "auto" else align, length.out = ncol(df))]
  body <- vapply(
    seq_len(nrow(df)),
    function(i) row(vapply(cols, `[[`, "", i)),
    character(1)
  )
  core <- sprintf(
    "three-line-table[\n%s\n]",
    paste0("  ", row(paste0("*", names(cols), "*")), "\n",
           "  ", row(sep), "\n",
           paste0("  ", body, collapse = "\n"))
  )
  if (is.null(caption)) return(paste0("#", core, "\n"))
  sprintf("#figure(\n%s,\n  caption: [%s],\n)\n", core, caption)
}

## 3. 入口函数 -------------------------------------------------------------
render_typst <- function(input, keep_typ = TRUE) {
  input <- normalizePath(input, mustWork = TRUE)
  dir <- dirname(input)
  typ <- sub("\\.Rtyp$", ".typ", basename(input))

  knitr::knit_hooks$set(
    source = hook_source, output = hook_output, plot = hook_plot,
    message = hook_output, warning = hook_output, error = hook_output
  )
  knitr::opts_chunk$set(
    dev = "svglite", dpi = 300, fig.width = 6, fig.height = 4,
    comment = "#>", collapse = TRUE
  )

  owd <- setwd(dir); on.exit(setwd(owd), add = TRUE) # 相对路径（图片、include）以文档为基准
  knitr::knit(basename(input), typ, quiet = TRUE)

  status <- system2("typst", c("compile", shQuote(typ)))
  if (status != 0L) stop("typst compile failed", call. = FALSE)
  if (!keep_typ) unlink(typ)

  invisible(sub("\\.typ$", ".pdf", file.path(dir, typ)))
}
