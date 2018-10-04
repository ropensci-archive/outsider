test_import <- function(repo) {
  pkgnm <- .repo_to_pkgnm(repo = repo)
  require(pkgnm, character.only = TRUE)
  fnames <- ls(paste0('package:', pkgnm))
  for (fname in fnames) {
    foo <- module_import(fname = fname, repo = repo)
    foo()
  }
  TRUE
}

test_install <- function(repo) {
  module_uninstall(repo =  repo)
  module_install(repo = repo)
  TRUE
}