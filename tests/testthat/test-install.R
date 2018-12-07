# TODO: add skips if no docker
# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'DomBennett/om..hello.world'
fname <- 'hello_world'

# PRE-TEST
if (module_installed(repo = repo)) {
  stop('Uninstall hello world before testing.')
}

# FUNCTIONS
pretest_install <- function() {
  if (!module_installed(repo = repo)) {
    suppressWarnings(module_install(repo = repo))
  }
}

# RUNNING
context('Testing \'modules\'')
withr::with_temp_libpaths(code = {
  on.exit(module_uninstall(repo = repo))
  test_that('module_install() and module_uninstall works', {
    expect_true(module_uninstall(repo = repo))
      with_mock(
        `outsider::is_docker_available` = function(...) FALSE,
        expect_error(suppressWarnings(module_install(repo = repo)))
      )
      expect_true(suppressWarnings(module_install(repo = repo)))
      expect_error(suppressWarnings(module_install(repo = repo)))
      require(package = .repo_to_pkgnm(repo = repo), character.only = TRUE)
      expect_true(module_uninstall(repo = repo))
  })
  test_that('module_import() works', {
    pretest_install()
    foo <- module_import(fname = fname, repo = repo)
    expect_true(inherits(foo, 'function'))
  })
  test_that('module_help() works', {
    pretest_install()
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
    with_mock(
      `outsider:::test_install` = function(...) TRUE,
      `outsider:::test_import` = function(...) TRUE,
      `outsider:::test_examples` = function(...) TRUE,
      expect_true(module_test(repo = repo))
    )
  })
})
