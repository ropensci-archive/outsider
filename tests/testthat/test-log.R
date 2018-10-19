# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'log\'')
test_that('log_set() works', {
  on.exit(outsider:::default_log_set())
  strms <- c('program_out', 'program_err',
             'docker_out', 'docker_err')
  for (strm in strms) {
    log_set(log = strm, val = 'set_so')
    expect_true(outsider:::log_get(log = strm) == 'set_so')
  }
  expect_error(log_set(log = 'not a log stream', val = 'set_so'))
})
test_that('log_get() works', {
  on.exit(outsider:::default_log_set())
  log_set(log = 'program_out', val = NULL)
  expect_true(outsider:::log_get('program_out'))
})
test_that('default_log_set() works', {
  expect_true(outsider:::default_log_set())
})
