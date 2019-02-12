library(outsider)
# wd is determined by key argument
arglist <- c('-a', 10, '-wd', 'path/to/wd', '-b', 'model2')
(.wd_get(arglist = arglist, key = '-wd'))
# wd is determined by an index
arglist <- c('path/to/wd', '-a', 10, '-b', 'model2')
(.wd_get(arglist = arglist, i = 1))
