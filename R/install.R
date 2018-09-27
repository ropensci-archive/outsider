module_install <- function(repo) {
  dockerfile_url <- paste0('https://raw.githubusercontent.com/',
                           repo, '/master/Dockerfile')
  docker_build(img_id = repo, url = dockerfile_url)
  devtools::install_github(repo = repo)
}

import <- function(fname, repo) {
  pkgnm <- repo_to_pkgnm(repo)
  getFromNamespace(x = fname, ns = pkgnm)
}
