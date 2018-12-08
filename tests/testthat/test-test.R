# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'internal\'')
test_that('fnames_get() works', {
  res <- with_mock(
    `outsider:::repo_to_pkgnm` = function(...) 'outsider',
    outsider:::fnames_get(repo = '')
  )
  expect_true('module_install' %in% res)
})
context('Testing \'test\'')
test_that('install_test() works', {
  with_mock(
    `outsider:::install` = function(...) stop(''),
    `outsider:::module_uninstall` = function(...) FALSE,
    expect_error(outsider:::install_test(repo = '', tag = 'latest'))
  )
  with_mock(
    `outsider:::install` = function(...) TRUE,
    `outsider:::module_uninstall` = function(...) TRUE,
    expect_true(outsider:::install_test(repo = '', tag = 'latest'))
  )
})
test_that('import_test() works', {
  with_mock(
    `outsider:::fnames_get` = function(...) 'foo',
    `outsider::module_import` = function(...) NULL,
    expect_false(outsider:::import_test(repo = ''))
  )
  with_mock(
    `outsider:::fnames_get` = function(...) 'foo',
    `outsider::module_import` = function(...) function() {},
    expect_true(outsider:::import_test(repo = repo))
  )
})
test_that('examples_test() works', {
  with_mock(
    `outsider:::fnames_get` = function(...) 'foo',
    `outsider:::ex_source` = function(...) stop(),
    expect_false(outsider:::examples_test(repo = ''))
  )
  with_mock(
    `outsider:::fnames_get` = function(...) 'foo',
    `outsider:::ex_source` = function(...) NULL,
    expect_true(outsider:::examples_test(repo = ''))
  )
})
context('Testing \'unittest\'')
test_that('datadir_get() works', {
  expect_true(grepl(pattern = 'data', x = outsider:::datadir_get()))
})
test_that('vars_get() works', {
  expect_true(grepl(pattern = 'hello', x = outsider:::vars_get('repo')))
})