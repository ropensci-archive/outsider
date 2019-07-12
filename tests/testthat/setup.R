# Vars ----
wd <- getwd()
if (grepl("testthat", wd)) {
  datadir <- "data"
} else {
  datadir <- file.path("tests", "testthat", "data")
}

# Mocks ----
# github
mock_github_search <- function() {
  readRDS(file = file.path(datadir, 'github_search.RData'))
}
mock_github_repo_search <- function(repo) {
  readRDS(file = file.path(datadir, 'github_repo_search.RData'))
}
mock_github_tags <- function(repos) {
  readRDS(file = file.path(datadir, 'github_tags.RData'))
}
# gitlab
mock_gitlab_search <- function() {
  readRDS(file = file.path(datadir, 'gitlab_search.RData'))
}
mock_gitlab_repo_search <- function(repo) {
  readRDS(file = file.path(datadir, 'gitlab_repo_search.RData'))
}
mock_gitlab_tags <- function(repo_ids) {
  readRDS(file = file.path(datadir, 'gitlab_tags.RData'))
}
# bitbucket
mock_bitbucket_repo_search <- function(repo) {
  readRDS(file = file.path(datadir, 'bitbucket_repo_search.RData'))
}
mock_bitbucket_tags <- function(repos) {
  readRDS(file = file.path(datadir, 'bitbucket_tags.RData'))
}
# yaml
mock_yaml_fetch <- function(url) {
  outsider:::yaml_fetch(url = file.path(datadir, 'om.yml'))
}
