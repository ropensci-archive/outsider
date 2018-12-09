# LIBS
library(outsider)
library(testthat)

# VARS
repo <- outsider:::vars_get('repo')
img <- outsider:::vars_get('img')
pkgnm <- outsider:::vars_get('pkgnm')
program <- outsider:::vars_get('program')

# RUNNING
context('Testing \'identities\'')
test_that('ids_get() works', {
  imgs <- tibble::as_tibble(list('repository' = img))
  res <- with_mock(
    `outsider:::pkgnm_to_img` = function(...) img,
    `outsider:::docker_ps_count` = function(...) 0,
    `outsider:::docker_img_ls` = function(...) imgs,
    outsider:::ids_get(pkgnm = pkgnm)
  )
  expect_true(all(names(res) %in% c('img', 'cntnr', 'tag')))
  imgs <- tibble::as_tibble(list('repository' = img, 'tag' = 'latest'))
  res <- with_mock(
    `outsider:::pkgnm_to_img` = function(...) img,
    `outsider:::docker_ps_count` = function(...) 0,
    `outsider:::docker_img_ls` = function(...) imgs,
    outsider:::ids_get(pkgnm = pkgnm)
  )
  expect_true(all(names(res) %in% c('img', 'cntnr', 'tag')))
})
test_that('repo_to_img() works', {
  res <- with_mock(
    `outsider:::pkgnm_to_img` = function(...) img,
    outsider:::repo_to_img(repo = repo)
  )
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
test_that('pkgnm_to_img() works', {
  res <- outsider:::pkgnm_to_img(pkgnm = pkgnm, 'jeff')
  expect_true(grepl(pattern = 'jeff', x = res))
})
