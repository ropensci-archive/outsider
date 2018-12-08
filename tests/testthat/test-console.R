# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'console\'')
test_that('.onAttach() works', {
  expect_true(outsider:::.onAttach())
})
test_that('char() works', {
  expect_true(is.character(outsider:::char('char')))
})
test_that('stat() works', {
  expect_true(is.character(outsider:::stat('stat')))
})
test_that('cat_line() works', {
  expect_null(outsider:::cat_line('cat this'))
})
test_that('celebrate() works', {
  res <- lapply(1:10, function(x) outsider:::celebrate())
  expect_null(res[[1]])
})
test_that('comfort() works', {
  res <- lapply(1:10, function(x) outsider:::comfort())
  expect_null(res[[1]])
})
