# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'console\'')
test_that('char() works', {
  expect_true(is.character(outsider:::char('char')))
})
test_that('stat() works', {
  expect_true(is.character(outsider:::stat('stat')))
})
test_that('cat_line() works', {
  expect_null(outsider:::cat_line('cat this'))
})
