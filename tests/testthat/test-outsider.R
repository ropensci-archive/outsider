# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'outsider\'')
test_that("outsider class and methods works", {
  container <- structure(list(), class = 'container')
  # test init
  otsdr <- with_mock(
    `outsider:::container_init` = function(...) container,
    .outsider_init(repo = 'user/repo')
  )
  expect_true(inherits(otsdr, 'outsider'))
  # test print
  with_mock(
    `outsider:::status.container` = function(...) 'This is a mock',
    expect_null(print(otsdr))
  )
  # test run
  otsdr$cmd <- 'cmd'
  with_mock(
    `outsider:::start.container` = function(x, ...) TRUE,
    `outsider:::halt.container` = function(x, ...) TRUE,
    `outsider:::copy.container` = function(x, ...) TRUE,
    `outsider:::run.container` = function(x, ...) TRUE,
    expect_true(.run(otsdr))
  )
  otsdr$files_to_send <- 'file'
  with_mock(
    `outsider:::start.container` = function(x, ...) TRUE,
    `outsider:::halt.container` = function(x, ...) TRUE,
    `outsider:::copy.container` = function(x, ...) TRUE,
    `outsider:::run.container` = function(x, ...) TRUE,
    expect_true(.run(otsdr))
  )
  otsdr$wd <- 'wd'
  with_mock(
    `outsider:::start.container` = function(x, ...) TRUE,
    `outsider:::halt.container` = function(x, ...) TRUE,
    `outsider:::copy.container` = function(x, ...) TRUE,
    `outsider:::run.container` = function(x, ...) TRUE,
    expect_true(.run(otsdr))
  )
  with_mock(
    `outsider:::start.container` = function(x, ...) TRUE,
    `outsider:::halt.container` = function(x, ...) TRUE,
    `outsider:::copy.container` = function(x, ...) TRUE,
    `outsider:::run.container` = function(x, ...) FALSE,
    expect_false(.run(otsdr))
  )
  with_mock(
    `outsider:::start.container` = function(x, ...) FALSE,
    `outsider:::halt.container` = function(x, ...) TRUE,
    `outsider:::copy.container` = function(x, ...) TRUE,
    `outsider:::run.container` = function(x, ...) TRUE,
    expect_false(.run(otsdr))
  )
  with_mock(
    `outsider:::start.container` = function(x, ...) TRUE,
    `outsider:::halt.container` = function(x, ...) TRUE,
    `outsider:::copy.container` = function(x, ...) TRUE,
    `outsider:::exec.container` = function(x, ...) stop(),
    `outsider:::status.container` = function(...) 'This is a mock',
    expect_error(outsider:::.run.outsider(otsdr))
  )
})
