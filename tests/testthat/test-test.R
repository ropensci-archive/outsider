# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'dombennett/om..hello.world..1.0'

# PRE-TEST
if (module_installed(repo = repo)) {
  stop('Uninstall hello world before testing.')
}

# RUNNING
context('Testing \'test\'')
withr::with_temp_libpaths(code = {
  on.exit(module_uninstall(repo = repo))
  test_that('test_install() works', {
    res <- outsider:::test_install(repo = repo)
    expect_true(res)
    module_uninstall(repo = repo)
  })
  module_install(repo = repo)
  test_that('fnames_get() works', {
    res <- outsider:::fnames_get(repo = repo)
    expect_true(res == 'hello_world')
  })
  test_that('test_import() works', {
    expect_true(outsider:::test_import(repo = repo))
    with_mock(
      `outsider::module_import` = function(...) NULL,
      expect_false(outsider:::test_import(repo = repo))
    )
  })
  test_that('test_examples() works', {
    expect_true(outsider:::test_examples(repo = repo))
    with_mock(
      `outsider::module_import` = function(...) stop(),
      expect_false(outsider:::test_examples(repo = repo))
    )
  })
})