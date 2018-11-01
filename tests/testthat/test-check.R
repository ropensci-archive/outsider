# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'check\'')
test_that('is_docker_available() works', {
  expect_true(is.logical(outsider:::is_docker_available()))
})
test_that('build_status() works', {
  expect_true(is.logical(
    outsider:::build_status('DomBennett/om..hello.world..1.0')))
  res <- with_mock(
    `jsonlite::fromJSON` = function(...) list('total_count' = 0),
    expect_warning(outsider:::build_status('DomBennett/om..hello.world..1.0'))
  )
  expect_false(res)
  res <- with_mock(
    `jsonlite::fromJSON` = function(...) list('total_count' = 2),
    expect_warning(outsider:::build_status('DomBennett/om..hello.world..1.0'))
  )
  expect_false(res)
})
