# Framework copied from pkgdown
char <- function(x) {
  crayon::green(encodeString(x, quote = "'"))
}

stat <- function(...) {
  crayon::blue(...)
}

cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}
