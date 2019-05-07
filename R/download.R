url_make <- function(username, repo, ref = 'master',
                     service = c('github', 'bitbucket', 'gitlab')) {
  service <- match.arg(service)
  base_url <- switch(service, github = 'github.com',
                     bitbucket = 'bitbucket.org', gitlab = 'gitlab.com')
  command <- switch(service, github = 'archive', bitbucket = 'get',
                    gitlab = 'archive')
  paste0("https://", base_url, '/', username, '/', repo, "/", command, '/',
         ref, ".tar.gz")
}

download_and_install <- function(url, tag = 'latest', pull = TRUE,
                                 verbose = TRUE) {
  clean_up <- function(dd) {
    if (dir.exists(dd)) {
      unlink(x = dd, recursive = TRUE, force = TRUE)
    }
  }
  dd <- file.path(tempdir(check = TRUE), 'om_downloads')
  clean_up(dd)
  dir.create(dd)
  on.exit(expr = clean_up(dd))
  flpth <- file.path(dd, 'archive')
  utils::download.file(url = url, destfile = flpth, quiet = !verbose)
  if (!file.exists(flpth)) {
    stop(paste0('Could not download from ', char(url)), call. = FALSE)
  }
  utils::untar(tarfile = flpth, exdir = dd)
  x <- list.files(path = dd)
  x <- x[x != 'archive']
  install(flpth = file.path(dd, x), tag = tag, pull = pull, verbose = verbose)
}
