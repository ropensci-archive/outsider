# LIBS
library(outsider)
library(testthat)

# VARS
repo <- outsider:::vars_get('repo')
pkgnm <- outsider:::vars_get('pkgnm')
program <- outsider:::vars_get('program')

# RUNNING
context('Testing \'identities\'')
withr::with_temp_libpaths(code = {
  on.exit(module_uninstall(repo = repo))
  if (!outsider:::is_installed(repo = repo)) {
    suppressWarnings(module_install(repo = repo))
  }
  test_that('ids_get() works', {
    res <- outsider:::ids_get(pkgnm = pkgnm)
    expect_true(all(names(res) %in% c('img', 'cntnr', 'tag')))
  })
  test_that('repo_to_img() works', {
    res <- outsider:::repo_to_img(repo = repo)
    expect_false(grepl(pattern = '\\.\\.', x =  res))
    expect_false(res == repo)
  })
  test_that('pkgnm_to_repo() works', {
    res <- outsider:::pkgnm_to_repo(pkgnm = pkgnm)
    expect_true(res == repo)
  })
  test_that('repo_to_pkgnm() works', {
    res <- outsider:::repo_to_pkgnm(repo = repo)
    expect_true(res == pkgnm)
  })
  test_that('pkgnm_to_prgm() works', {
    res <- outsider:::pkgnm_to_prgm(pkgnm = pkgnm)
    expect_true(res == program)
  })
})
