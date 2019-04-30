# TODO: add skips if no docker
# LIBS
library(outsider)
library(testthat)

# VARS
repo <- outsider:::vars_get('repo')
pkgnm <- outsider:::vars_get('pkgnm')
fname <- outsider:::vars_get('fname')
img <- outsider:::vars_get('img')

# FUNCTIONS ----
mock_tags <- function(...) {
  readRDS(file = outsider:::datadir_get('tag_data.RData'))
}

# RUNNING
# Bad practice to test the internal functioning, but
# tests are too slow and require running in separate environments otherwise.
context('Testing \'install\'')
test_that('module_install() works', {
  with_mock(
    `outsider:::is_running_on_travis` = function() FALSE,
    `outsider:::build_status` = function(...) TRUE,
    `outsider.devtools:::is_docker_available` = function(...) TRUE,
    `outsider.devtools:::is_installed` = function(...) FALSE,
    `outsider.devtools:::install` = function(...) TRUE,
    `outsider:::tags` = mock_tags,
    expect_true(module_install(repo = repo))
  )
  with_mock(
    `outsider:::is_running_on_travis` = function() FALSE,
    `outsider:::build_status` = function(...) TRUE,
    `outsider.devtools:::is_docker_available` = function(...) TRUE,
    `outsider.devtools:::is_installed` = function(...) FALSE,
    `outsider.devtools:::install` = function(...) TRUE,
    `outsider:::tags` = mock_tags,
    expect_true(module_install(repo = repo, manual = TRUE))
  )
  with_mock(
    `outsider:::is_running_on_travis` = function() FALSE,
    `outsider:::build_status` = function(...) TRUE,
    `outsider.devtools:::is_docker_available` = function(...) TRUE,
    `outsider.devtools:::is_installed` = function(...) TRUE,
    `outsider.devtools:::install` = function(...) TRUE,
    `outsider:::tags` = mock_tags,
    expect_error(module_install(repo = repo))
  )
  with_mock(
    `outsider:::is_running_on_travis` = function() FALSE,
    `outsider:::build_status` = function(...) FALSE,
    `outsider.devtools:::is_docker_available` = function(...) TRUE,
    `outsider.devtools:::is_installed` = function(...) FALSE,
    `outsider.devtools:::install` = function(...) TRUE,
    `outsider:::tags` = mock_tags,
    expect_warning(module_install(repo = repo))
  )
  with_mock(
    `outsider:::is_running_on_travis` = function() FALSE,
    `outsider:::build_status` = function(...) FALSE,
    `outsider.devtools:::is_docker_available` = function(...) TRUE,
    `outsider.devtools:::is_installed` = function(...) FALSE,
    `outsider.devtools:::install` = function(...) TRUE,
    `outsider:::tags` = mock_tags,
    expect_warning(module_install(repo = repo))
  )
})
test_that('module_help() works', {
  expect_error(module_help(repo = 'githubuser/reponame'))
  with_mock(
    `outsider:::hlp_get` = function(...) TRUE,
    `outsider.devtools:::repo_to_pkgnm` = function(...) 'testthat',
    expect_true(module_help(repo = repo, fname = 'with_mock'))
  )
})
test_that('module_import() works', {
  expect_error(module_import(repo = 'githubuser/reponame', fname = 'foo'))
  with_mock(
    `outsider:::nmspc_get` = function(...) TRUE,
    `outsider.devtools:::repo_to_pkgnm` = function(...) 'testthat',
    expect_true(module_import(repo = repo, fname = 'with_mock'))
  )
})
test_that('module_uninstall() works', {
  with_mock(
    `outsider.devtools:::is_installed` = function(...) TRUE,
    `devtools::loaded_packages` = function(...) list('package' = pkgnm),
    `devtools::unload` = function(...) TRUE,
    `devtools::inst` = function(...) TRUE,
    `outsider.devtools::docker_img_rm` = function(...) TRUE,
    `outsider.devtools:::pkg_rm` = function(...) TRUE,
    expect_false(module_uninstall(repo = repo))
  )
})
test_that('module_installed() works', {
  imgs <- tibble::as_tibble(list('repository' = 'dombennett/om_hello.world'))
  res <- with_mock(
    `outsider:::installed_pkgs` = function() pkgnm,
    module_installed()
  )
  expect_true(inherits(res, 'tbl_df'))
  res <- with_mock(
    `outsider:::installed_pkgs` = function() pkgnm,
    `outsider.devtools:::repo_to_img` = function(...) img,
    `outsider.devtools:::docker_img_ls` = function(...) imgs,
    module_installed(show_images = TRUE)
  )
  expect_true(inherits(res, 'tbl_df'))
  expect_true(res[['img_exists']])
})
