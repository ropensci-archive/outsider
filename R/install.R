module_install <- function(repo) {
  dockerfile_url <- paste0('https://raw.githubusercontent.com/',
                           repo, '/master/Dockerfile')
  id <- sub(pattern = '/', replacement = '..', x = repo)
  docker_build(img_id = id, url = dockerfile_url)
  devtools::install_github(repo = repo)
}

