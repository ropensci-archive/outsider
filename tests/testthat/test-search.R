# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'dombennett/om..hello.world'

# FUNCTIONS
datadir_get <- function(subdir = "") {
  wd <- getwd()
  if (grepl("testthat", wd)) {
    datadir <- "data"
  }
  else {
    datadir <- file.path("tests", "testthat", "data")
  }
  file.path(datadir, subdir)
}
mock_search <- function(...) {
  readRDS(file = file.path(datadir_get(), 'om_search.RData'))
}
mock_yaml <- function(...) {
  readRDS(file = file.path(datadir_get(), 'om_yaml.RData'))
}

# RUNNING
context('Testing \'search\'')
test_that('available() works', {
  res <- with_mock(
    `outsider:::om_search` = mock_search,
    `outsider:::om_yaml` = mock_yaml,
    available()
  )
  expect_true(repo %in% tolower(rownames(res)))
})
test_that('om_search() works', {
  with_mock(
    `jsonlite::fromJSON` = function(...) list('incomplete_results' = FALSE,
                                              'items' = TRUE),
    expect_true(outsider:::om_search())
  )
  with_mock(
    `jsonlite::fromJSON` = function(...) list('incomplete_results' = TRUE,
                                              'items' = TRUE),
    expect_warning(outsider:::om_search())
  )
})
test_that('om_yaml() works', {
  res <- outsider:::om_yaml(repos = repo)
  expect_true(inherits(res, 'data.frame'))
  expect_true(rownames(res) == repo)
})
