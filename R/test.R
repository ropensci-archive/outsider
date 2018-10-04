fnames_get <- function(repo) {
  .get <- function(pkgnm) {
    suppressMessages(require(pkgnm, character.only = TRUE))
    ls(paste0('package:', pkgnm))
  }
  pkgnm <- .repo_to_pkgnm(repo = repo)
  fname_env <- new.env()
  fname_env$.get <- .get
  fname_env$.get(pkgnm = pkgnm)
}

test_examples <- function(repo) {
  base_ex_url <- paste0("https://raw.githubusercontent.com/", repo,
                        "/master/examples/")
  fnames <- fnames_get(repo = repo)
  ex_urls <- paste0(base_ex_url, fnames, '.R')
  for (i in seq_along(ex_urls)) {
    tryCatch(source(file = ex_urls[[i]], local = TRUE), error = function(e) {
      stop('Failed to run example for ', fnames[[i]], call. = FALSE)
    })
  }
  TRUE
}

test_import <- function(repo) {
  fnames <- fnames_get(repo = repo)
  for (fname in fnames) {
    foo <- module_import(fname = fname, repo = repo)
    if (!inherits(foo, 'function')) {
      stop('Unable to import ', fname, ' correctly', call. = FALSE)
    }
  }
  TRUE
}

test_install <- function(repo) {
  module_uninstall(repo =  repo)
  module_install(repo = repo)
  TRUE
}