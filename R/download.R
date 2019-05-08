
#' @name url_make
#' @title Make download URL
#' @description Return a url of the likely download .tar.gz link for a
#' repository
#' @param username Username of repo
#' @param repo Repository name
#' @param ref Reference (e.g. branch, tag)
#' @param service One of 'github', 'bitbucket' or 'gitlab'
#' @return character(1)
# TODO: switch to APIs? More reliable, but also more coding.
url_make <- function(username, repo, ref = 'master',
                     service = c('github', 'bitbucket', 'gitlab')) {
  service <- match.arg(service)
  base_url <- switch(service, github = 'github.com',
                     bitbucket = 'bitbucket.org', gitlab = 'gitlab.com')
  command <- switch(service, github = 'archive', bitbucket = 'get',
                    gitlab = '-/archive')
  filename <- switch(service, github = '', bitbucket = '',
                     gitlab = paste0('/', repo, '-', ref))
  res <- paste0("https://", base_url, '/', username, '/', repo, "/", command,
                '/', ref, filename, ".tar.gz")
  if (!RCurl::url.exists(res)) {
    msg <- paste0(char(res), ' is not available for download. ',
                  "Are you sure the repo details are correct?")
    stop(msg, call. = FALSE)
  }
  res
}

#' @name download_and_install
#' @title Download and install module
#' @description Download and build an outsider module. The function will
#' download the module to a temporary directory and then install.
#' @param url .tar.gz link
#' @param tag Docker tag, default 'latest'
#' @param pull Attempt to pull from Docker Hub?
#' @param verbose Be verbose? Default TRUE.
#' @details \code{url} is expected to be a .tar.gz link.
#' @return logical(1)
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
  download_file(url = url, destfile = flpth, quiet = !verbose)
  if (!file.exists(flpth)) {
    stop(paste0('Could not download from ', char(url)), call. = FALSE)
  }
  untar2(tarfile = flpth, exdir = dd)
  x <- list.files(path = dd)
  x <- x[x != 'archive']
  install(flpth = file.path(dd, x), tag = tag, pull = pull, verbose = verbose)
}
download_file <- function(...) {
  utils::download.file(...)
}
untar2 <- function(...) {
  utils::untar(...)
}
