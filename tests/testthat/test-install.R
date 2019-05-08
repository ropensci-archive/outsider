context('Testing \'install\'')
test_that('module_install() works', {
  with_mock(
    `outsider:::is_docker_available` = function(...) TRUE,
    `outsider.base:::install` = function(...) TRUE,
    `outsider:::download_and_install` = function(...) TRUE,
    `outsider:::url_make` = function(...) '',
    expect_true(module_install(repo = repo, force = TRUE)),
    expect_true(module_install(url = '', force = TRUE)),
    expect_true(module_install(filepath = '', force = TRUE)),
    expect_error(module_install(filepath = '', url = '', force = TRUE))
  )
})
test_that('module_help() works', {
  expect_error(module_help(repo = 'githubuser/reponame'))
  with_mock(
    `outsider:::hlp_get` = function(...) TRUE,
    `outsider:::pkgnm_guess` = function(...) 'testthat',
    expect_true(module_help(repo = repo, fname = 'with_mock'))
  )
})
test_that('module_import() works', {
  expect_error(module_import(repo = 'githubuser/reponame', fname = 'foo'))
  with_mock(
    `outsider:::nmspc_get` = function(...) TRUE,
    `outsider:::pkgnm_guess` = function(...) 'testthat',
    expect_true(module_import(repo = repo, fname = 'with_mock'))
  )
})
test_that('is_module_installed() works', {
  with_mock(
    `outsider:::pkgnm_guess` = function(...) NULL,
    expect_false(is_module_installed(repo = repo))
  )
  with_mock(
    `outsider:::pkgnm_guess` = function(...) pkgnm,
    expect_true(is_module_installed(repo = repo))
  )
})
test_that('module_uninstall() works', {
  with_mock(
    `outsider:::pkgnm_guess` = function(...) pkgnm,
    `outsider.base:::uninstall` = function(...) TRUE,
    `outsider:::is_module_installed` = function(...) FALSE,
    expect_true(module_uninstall(repo = repo))
  )
})
test_that('module_installed() works', {
  NULL
})
