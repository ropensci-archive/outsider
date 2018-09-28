module_install <- function(repo) {
  dockerfile_url <- paste0('https://raw.githubusercontent.com/',
                           repo, '/master/Dockerfile')
  docker_build(img_id = repo, url = dockerfile_url)
  devtools::install_github(repo = repo)
  pkgnm <- repo_to_pkgnm(repo)
  invisible(pkgnm %in% installed.packages())
}

module_uninstall <- function(repo) {
  pkgnm <- repo_to_pkgnm(repo)
  if (pkgnm %in% installed.packages()) {
    docker_rm(img_id = repo)
    suppressMessages(utils::remove.packages(pkgs = pkgnm))
  }
  invisible(!pkgnm %in% installed.packages())
}

module_import <- function(fname, repo) {
  pkgnm <- repo_to_pkgnm(repo)
  getFromNamespace(x = fname, ns = pkgnm)
}

module_help <- function(repo, fname = NULL) {
  pkgnm <- repo_to_pkgnm(repo)
  if (is.null(fname)) {
    utils::help(package = (pkgnm))
  } else {
    utils::help(package = (pkgnm), topic = (fname))
  }
}
