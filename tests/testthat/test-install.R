# TODO: add skips if no docker
# LIBS
library(outsider)
library(testthat)

# VARS
repo <- outsider:::vars_get('repo')
pkgnm <- outsider:::vars_get('pkgnm')
fname <- outsider:::vars_get('fname')

# RUNNING
context('Testing \'install\'')
test_that("is_installed() works", {
  with_mock(
    `outsider::module_installed` = function(...) data.frame(repo = 'this/repo'),
    expect_true(outsider:::is_installed(repo = 'this/repo'))
  )
  with_mock(
    `outsider::module_installed` = function(...) data.frame(repo = 'this/repo'),
    expect_false(outsider:::is_installed(repo = 'that/repo'))
  )
})
test_that("install() works", {
  # Lots of internal tests for this function -- required to ensure consistent
  #  behaviour.
  with_mock(
    `outsider:::is_installed` = function(...) FALSE,
    `devtools::install_github` = function(...) TRUE,
    `outsider:::docker_pull` = function(...) TRUE,
    `outsider:::docker_build` = function(...) TRUE,
    `outsider::module_uninstall` = function(...) TRUE,
    `outsider:::repo_to_img` = function(...) list(),
    expect_false(outsider:::install(repo = 'this/repo', tag = ''))
  )
  with_mock(
    `outsider:::is_installed` = function(...) TRUE,
    `devtools::install_github` = function(...) TRUE,
    `outsider:::docker_pull` = function(...) TRUE,
    `outsider:::docker_build` = function(...) TRUE,
    `outsider::module_uninstall` = function(...) TRUE,
    `outsider:::repo_to_img` = function(...) list(),
    expect_true(outsider:::install(repo = 'this/repo', tag = '',
                                   dockerfile_url = ''))
  )
  with_mock(
    `outsider:::is_installed` = function(...) TRUE,
    `devtools::install_github` = function(...) TRUE,
    `outsider:::docker_pull` = function(...) TRUE,
    `outsider:::docker_build` = function(...) TRUE,
    `outsider::module_uninstall` = function(...) TRUE,
    `outsider:::repo_to_img` = function(...) list(),
    expect_true(outsider:::install(repo = 'this/repo', tag = ''))
  )
})
test_that('module_[install/uninstall/import/help]() work', {
  withr::with_temp_libpaths(code = {
    #try(utils::remove.packages(pkgnm), silent = TRUE)
    with_mock(
      `outsider:::build_status` = function(...) TRUE,
      `outsider:::is_docker_available` = function(...) TRUE,
      `outsider:::docker_build` = function(...) TRUE,
      `outsider:::docker_pull` = function(...) TRUE,
      expect_true(module_install(repo = repo))
    )
    with_mock(
      `outsider:::.help` = function(...) TRUE,
      expect_true(module_help(repo = repo)),
      expect_true(module_help(repo = repo, fname = fname))
    )
    expect_true(inherits(module_import(fname = fname, repo = repo), 'function'))
    with_mock(
      `outsider:::build_status` = function(...) FALSE,
      `outsider:::is_docker_available` = function(...) TRUE,
      expect_warning(expect_error(module_install(repo = repo)))
    )
    expect_true(module_uninstall(repo = repo))
    with_mock(
      `outsider:::build_status` = function(...) TRUE,
      `outsider:::is_docker_available` = function(...) TRUE,
      `outsider:::docker_build` = function(...) TRUE,
      `outsider:::docker_pull` = function(...) TRUE,
      expect_true(module_install(repo = repo, manual = TRUE))
    )
    expect_true(module_uninstall(repo = repo))
  })
})
