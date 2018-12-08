# TODO: add more mock data to reduce dependance on internet
# LIBS
library(outsider)
library(testthat)

# VARS
repo <- outsider:::vars_get('repo')

# FUNCTIONS
mock_repo_search_0 <- function(...) {
  readRDS(file = file.path(outsider:::datadir_get(), 'repo_search.RData'))
}
mock_repo_search_1 <- function(...) {
  res <- mock_repo_search_0()
  res[['total_count']] <- 0
  res
}
mock_repo_search_2 <- function(...) {
  res <- mock_repo_search_0()
  res[['total_count']] <- 2
  res
}
mock_all_search <- function(...) {
  readRDS(file = file.path(outsider:::datadir_get(), 'all_search.RData'))
}
mock_all_search_bad <- function(...) {
  res <- mock_all_search()
  res[['incomplete_results']] <- TRUE
  res
}

# RUNNING
context('Testing \'search\'')
test_that('repo_search() works', {
  with_mock(
    `jsonlite::fromJSON` = mock_repo_search_0,
    expect_true(inherits(outsider:::repo_search(repo = repo), 'data.frame'))
  )
  with_mock(
    `jsonlite::fromJSON` = mock_repo_search_1,
    expect_warning(outsider:::repo_search(repo = repo))
  )
  with_mock(
    `jsonlite::fromJSON` = mock_repo_search_2,
    expect_warning(outsider:::repo_search(repo = repo))
    )
})
test_that('all_search() works', {
  with_mock(
    `jsonlite::fromJSON` = mock_all_search_bad,
    expect_warning(expect_true(inherits(outsider:::all_search(), 'data.frame')))
  )
})
test_that('build_status() works', {
  with_mock(
    `outsider:::repo_search` = function(repo) list(),
    `jsonlite::fromJSON` = function(...) stop(),
    expect_false(outsider:::build_status(repo = repo))
  )
  with_mock(
    `outsider:::repo_search` = function(repo) list(),
    `jsonlite::fromJSON` = function(...) list('last_build_status' = 0),
    expect_true(outsider:::build_status(repo = repo))
  )
})
test_that('read_yaml() works', {
  # TODO: with mock?
  res <- outsider:::read_yaml(repo = repo)
  expect_true(inherits(res, 'list'))
})
test_that('yaml() works', {
  # TODO: with mock?
  res <- outsider:::yaml(repos = repo)
  expect_true(inherits(res, 'tbl_df'))
})
test_that('tags() works', {
  # TODO: with mock?
  res <- outsider:::tags(repos = repo)
  expect_true(inherits(res, 'tbl_df'))
})
test_that('module_search() works', {
  res <- with_mock(
    `jsonlite::fromJSON` = mock_all_search,
    module_search()
  )
  expect_true(inherits(res, 'character'))
})
test_that('module_details() works', {
  # TODO: with mock?
  res <- module_details(repo = c(repo, repo))
  expect_true(inherits(res, 'tbl_df'))
})
test_that('module_exists() works', {
  with_mock(
    `outsider:::build_status` = function(...) TRUE,
    expect_true(all(module_exists(repo = c(repo, repo))))
  )
})
