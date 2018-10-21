# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'dombennett/om..hello.world..1.0'

# PRE-TEST
if (module_installed(repo = repo)) {
  stop('Uninstall hello world before testing.')
}

# FUNCTIONS
pretest_install <- function() {
  if (!module_installed(repo = repo)) {
    module_install(repo = repo)
  }
}

# RUNNING
context('Testing \'test\'')
test_that('test_install() works', {
  with_mock(
    `outsider:::.module_install` = function(...) stop(''),
    `outsider:::module_uninstall` = function(...) FALSE,
    expect_error(outsider:::test_install(repo = repo))
  )
  with_mock(
    `outsider:::.module_install` = function(...) TRUE,
    `outsider:::module_uninstall` = function(...) TRUE,
    expect_true(outsider:::test_install(repo = repo))
  )
})
withr::with_temp_libpaths(code = {
  pretest_install()
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