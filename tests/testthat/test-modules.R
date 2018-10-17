# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'DomBennett/om..hello.world..1.0'
fname <- 'hello_world'

# PRE-TEST
if (module_installed(repo = repo)) {
  stop('Uninstall hello world before testing.')
}

# RUNNING
context('Testing \'modules\'')
# TODO: reduce runtime
withr::with_temp_libpaths(code = {
  on.exit(module_uninstall(repo = repo))
  test_that('module_install() works', {
      with_mock(
        `outsider::is_docker_available` = function(...) FALSE,
        expect_error(module_install(repo = repo))
      )
      expect_true(module_install(repo = repo))
      expect_error(module_install(repo = repo))
  })
  test_that('module_uninstall() works', {
    expect_true(module_uninstall(repo = repo))
    expect_true(module_install(repo = repo))
    expect_true(module_uninstall(repo = repo))
  })
  test_that('module_import() works', {
    on.exit(module_uninstall(repo = repo))
    expect_true(module_install(repo = repo))
    foo <- module_import(fname = fname, repo = repo)
    expect_true(inherits(foo, 'function'))
  })
  test_that('module_help() works', {
    on.exit(module_uninstall(repo = repo))
    expect_true(module_install(repo = repo))
    help_files <- module_help(fname = fname, repo = repo)
    expect_true(inherits(help_files, 'help_files_with_topic'))
  })
  test_that('module_test() works', {
    with_mock(
      `outsider:::test_install` = function(...) stop(''),
      expect_error(module_test(repo = repo))
    )
    with_mock(
      `outsider:::test_import` = function(...) stop(''),
      expect_error(module_test(repo = repo))
    )
    with_mock(
      `outsider:::test_examples` = function(...) stop(''),
      expect_error(module_test(repo = repo))
    )
    expect_true(module_test(repo = repo))
  })
})
