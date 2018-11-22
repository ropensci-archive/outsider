# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'dombennett/om..hello.world'
pkgnm <- 'om..hello.world..dombennett'
prgrm_nm <- 'hello.world'

# RUNNING
context('Testing \'identities\'')
withr::with_temp_libpaths(code = {
  on.exit(module_uninstall(repo = repo))
  if (!module_installed(repo = repo)) {
    suppressWarnings(module_install(repo = repo))
  }
  test_that('.ids_get() works', {
    res <- .ids_get(pkgnm = pkgnm)
    expect_true(all(names(res) %in% c('img_id', 'cntnr_id')))
  })
  test_that('.repo_to_img() works', {
    res <- .repo_to_img(repo = repo)
    expect_false(grepl(pattern = '\\.\\.', x =  res))
    expect_false(res == repo)
  })
  test_that('.pkgnm_to_repo() works', {
    res <- .pkgnm_to_repo(pkgnm = pkgnm)
    expect_true(res == repo)
  })
  test_that('.repo_to_pkgnm() works', {
    res <- .repo_to_pkgnm(repo = repo)
    expect_true(res == pkgnm)
  })
  test_that('.pkgnm_to_prgm() works', {
    res <- .pkgnm_to_prgm(pkgnm = pkgnm)
    expect_true(res == prgrm_nm)
  })
})
