# Module test functions

# Internal ----
# Ensure tests do not run on Travis-CI
is_running_on_travis <- function() {
  Sys.getenv("CI") == "true" && Sys.getenv("TRAVIS") == "true"
}

#' @name fnames_get
#' @title Function names for module
#' @description Return function names of all available functions for an
#' installed outsider modules
#' @param repo Module repo
#' @return character vector
#' @family private
fnames_get <- function(repo) {
  .get <- function(pkgnm) {
    suppressMessages(require(pkgnm, character.only = TRUE))
    ls(paste0('package:', pkgnm))
  }
  pkgnm <- repo_to_pkgnm(repo = repo)
  fname_env <- new.env()
  fname_env$.get <- .get
  fname_env$.get(pkgnm = pkgnm)
}

# Tests ----
#' @name examples_test
#' @title Run each example of an outsider module
#' @description Return TRUE if all of the outsider module functions successfully
#' run.
#' @param repo Module repo
#' @return logical
#' @family private
examples_test <- function(repo) {
  res <- TRUE
  base_ex_url <- paste0("https://raw.githubusercontent.com/", repo,
                        "/master/examples/")
  fnames <- fnames_get(repo = repo)
  ex_urls <- paste0(base_ex_url, fnames, '.R')
  for (i in seq_along(ex_urls)) {
    res <- tryCatch(expr = {
      source(file = ex_urls[[i]], local = TRUE)
      TRUE
      }, error = function(e) {
        message('Failed to run example for `', fnames[[i]], '`')
        FALSE
        })
  }
  res
}

#' @name import_test
#' @title Test whether module functions can be imported
#' @description Return TRUE if all of the outsider module functions are
#' successfully imported.
#' @param repo Module repo
#' @return logical
#' @family private
import_test <- function(repo) {
  res <- TRUE
  fnames <- fnames_get(repo = repo)
  for (fname in fnames) {
    foo <- module_import(fname = fname, repo = repo)
    if (!inherits(foo, 'function')) {
      message('Unable to import `', fname, '` correctly')
      res <- FALSE
    }
  }
  res
}

#' @name install_test
#' @title Test whether module can be installed
#' @description Return TRUE if the outsider module successfully installs.
#' @param repo Module repo
#' @param tag Docker tag
#' @return logical
#' @family private
install_test <- function(repo, tag) {
  module_uninstall(repo = repo)
  install(repo = repo, tag = tag)
  TRUE
}

# Unittest ----
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

vars_get <- function(what) {
  vars <- list('repo' = 'dombennett/om..hello.world',
               'pkgnm' = 'om..hello.world..dombennett',
               'program' = 'hello.world')
  vars[[what]]
}
