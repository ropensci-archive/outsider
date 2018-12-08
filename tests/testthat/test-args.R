# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'args\'')
test_that('args_get() works', {
  foo <- function(...) {
    outsider:::args_get()
  }
  res <- foo('a', 'b', 'c')
  expect_equal(res, list('a', 'b', 'c'))
})
test_that('to_basename() works', {
  expctd <- list.files(getwd())[1]
  args <- c(file.path(getwd(), expctd), 'arg1', 'arg2')
  expect_true(outsider:::to_basename(args)[1] == expctd)
})
test_that('is_filepath() works', {
  files <- list.files(getwd())
  expect_true(all(outsider:::is_filepath(files)))
})
a <- 10L
test_that('.args_get() works', {
  res <- .arglist_get(a, 'b', 'c')
  expect_equal(res, c(10L, 'b', 'c'))
})
test_that('.filestosend_get() works', {
  # nothin in, nothin out
  expect_equal(.filestosend_get(character(0)), character())
  flnm <- 'testfile.txt'
  write('test', file = flnm)
  on.exit(file.remove(flnm))
  res <- .filestosend_get(c('notafile', flnm))
  expect_true(res == flnm)
  res <- .filestosend_get(c('notafile', flnm), wd = getwd())
  expect_true(file.path(getwd(), flnm) %in% res)
})
test_that('.wd_get() works', {
  # nothin in, nothin out
  expect_equal(.wd_get(character(0)), character())
  arglist <- c('1', '-wd', 'thisiswd/', '--otherarg')
  expect_equal(.wd_get(arglist), getwd())
  expect_equal(.wd_get(arglist, key = '-wd'), 'thisiswd/')
  arglist <- c('thisiswd/inputfile', '--otherarg', '--index', '1')
  expect_equal(.wd_get(arglist, i = 1, key = '-wd'), 'thisiswd/inputfile')
  arglist <- c('inputfile', '--otherarg', '--index', '1', '-wd', 'thisiswd/')
  expect_equal(.wd_get(arglist, i = 1, key = '-wd'), 'thisiswd/')
})
test_that('.dirpath_get() works', {
  # nothin in, nothin out
  expect_equal(.dirpath_get(character(0)), character())
  # if dirpath already, dirpath returned
  datapth <- outsider:::datadir_get()
  expect_equal(.dirpath_get(datapth), datapth)
  # drop filename
  expect_equal(.dirpath_get(paste0(datapth, 'afile.txt')), datapth)
})
test_that('.arglist_parse() works', {
  # nothin in, nothin out
  expect_equal(.arglist_parse(character(0)), character())
  # path normalisation
  res <- .arglist_parse(arglist = paste0(outsider:::datadir_get()))
  expect_equal(res, 'data')
  res <- .arglist_parse(arglist = 'not/a/real/file/path')
  expect_equal(res, 'not/a/real/file/path')
  # drop keyvals
  res <- .arglist_parse(arglist = c('-wd', 'thisiswd/', '-verbosity', '2',
                                    'otherarg'),
                        keyvals_to_drop = c('-wd', '-verbosity'))
  expect_equal(res, 'otherarg')
  # drop vals
  res <- .arglist_parse(arglist = c('-wd', 'thisiswd/', '-verbosity', '2',
                                    'otherarg', '--unwanted1', '--unwanted2'),
                        keyvals_to_drop = c('-wd', '-verbosity'),
                        vals_to_drop = c('--unwanted1', '--unwanted2'))
  expect_equal(res, 'otherarg')
})
