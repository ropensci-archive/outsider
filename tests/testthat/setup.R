# Vars ----
repo <- 'dombennett/om..hello.world'
pkgnm <- 'om..hello.world'
wd <- getwd()
if (grepl("testthat", wd)) {
  datadir <- "data"
} else {
  datadir <- file.path("tests", "testthat", "data")
}

# Functions ----
mock_repo_search_0 <- function(...) {
  readRDS(file = file.path(datadir, 'repo_search.RData'))
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
  readRDS(file = file.path(datadir, 'all_search.RData'))
}
mock_all_search_bad <- function(...) {
  res <- mock_all_search()
  res[['incomplete_results']] <- TRUE
  res
}
mock_tags <- function(...) {
  readRDS(file = outsider:::datadir_get('tag_data.RData'))
}
