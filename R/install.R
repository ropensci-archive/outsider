
#' @name user_warn
#' @title Warn users on the dangers of outsider modules
#' @description Warn users on the dangers of installing an outsider module
#' whose origin is potentially unknown.
#' @details Prints additional info to screen based on arguments given.
#' @param address repository address as a list
#' @param url URL download link
#' @param flpth Filepath install link
#' @return Logical
user_warn <- function(pkgnm) {
  # TODO: richer warnings for GitHub, BitBucket and GitLab
  msg <- readLines(con = system.file('install_warning.txt',
                                     package = 'outsider'))
  ncols <- nchar(msg[[1]])
  msg <- paste0(msg, collapse = '\n')
  if (!is.null(address)) {
    msg <- paste0(msg, '\nRepo:\n    ', address[['username']],
                  address[['repo']])
    msg <- paste0(msg, '\nOn:\n    ', address[['service']])
  }
  if (!is.null(url)) {
    msg <- paste0(msg, '\nVia:\n    ', url)
  }
  if (!is.null(flpth)) {
    msg <- paste0(msg, '\nVia:\n    ', flpth)
  }
  msg <- paste0(msg, '\n', paste0(rep('-', ncols), collapse = ''))
  message(crayon::silver(msg))
  readline(prompt = 'Enter any key to continue or press Esc to quit ')
  TRUE
}

# Public ----
#' @name module_install
#' @title Install an outsider module
#' @description Install a module
#' @param repo Module repo, character.
#' @param url URL to downloadable .tar.gz of module, character.
#' @param filepath Filepath to uncompressed directory of module, character.
#' @param tag Module version, default latest. Character.
#' @param manual Build the docker image? Default FALSE. Logical.
#' @param verbose Be verbose? Default FALSE.
#' @param force Ignore warnings and install anyway? Default FALSE.
#' @return Logical
#' @example examples/module_install.R
#' @export
module_install <- function(repo = NULL, url = NULL, filepath = NULL,
                           service = c('github', 'bitbucket', 'gitlab'),
                           tag = 'latest', manual = FALSE,
                           verbose = FALSE, force = FALSE) {
  res <- FALSE
  is_docker_available()
  if (length(c(repo, url, filepath)) != 1) {
    msg <- paste0('Must provide just 1 variable to either ', char('repo'), ', ',
                  char('url'), ' or ', char('filepath'))
    stop(msg)
  }
  if (!is.null(repo)) {
    service <- match.arg(service)
    install_repo <- switch(service, github = remotes::install_github,
                           gitlab = remotes::install_gitlab,
                           bitbucket = remotes::install_bitbucket)
    pkgnm <- install_repo(repo = repo, force = TRUE, quiet = !verbose,
                          reload = TRUE, build = FALSE)
  }
  if (!is.null(url)) {
    pkgnm <- remotes::install_url(url = url, force = TRUE, quiet = !verbose,
                                  reload = TRUE, build = FALSE)
  }
  if (!is.null(filepath)) {
    pkgnm <- remotes::install_local(path = filepath, force = TRUE,
                                    quiet = !verbose, reload = TRUE,
                                    build = FALSE)
  }
  if (force) {
    user_warn(pkgnm = pkgnm)
  }
  res <- image_install(pkgnm = pkgnm, tag = tag, pull = !manual)
  invisible(res)
}

#' @name is_module_installed
#' @title Is module installed?
#' @description Uninstall outsider module and removes it from your docker
#' @param repo Module repo
#' @details If program is successfully removed from your system, TRUE is
#' returned else FALSE.
#' @example examples/module_install.R
#' @return Logical
#' @export
#' @family user
is_module_installed <- function(repo) {
  !is.null(pkgnm_guess(repo = repo, call_error = FALSE))
}

#' @name module_uninstall
#' @title Uninstall and remove a module
#' @description Uninstall outsider module and removes it from your docker
#' @param repo Module repo
#' @details If program is successfully removed from your system, TRUE is
#' returned else FALSE.
#' @example examples/module_install.R
#' @return Logical
#' @export
#' @family user
module_uninstall <- function(repo) {
  pkgnm <- pkgnm_guess(repo = repo, call_error = FALSE)
  if (is.null(pkgnm)) {
    return(invisible(TRUE))
  }
  message(paste0('Removing ', char(pkgnm)))
  uninstall(pkgnm = pkgnm)
  invisible(!is_module_installed(repo = repo))
}

#' @name module_installed
#' @title Which outsider modules are installed?
#' @description Returns tbl_df of details for all outsider modules
#' installed on the user's computer.
#' @return tbl_df
#' @example examples/module_installed.R
#' @export
#' @family user
# TODO
module_installed <- function() {
  NULL
}
# module_installed <- function(show_images = FALSE) {
#   mdls <- modules_list()
#   if (length(mdls) == 0) {
#     return(tibble::as_tibble(x = list()))
#   }
#   repos <- vapply(X = mdls, FUN = pkgnm_guess, character(1))
#   if (show_images) {
#     imgnms <- vapply(X = repos, FUN = function(x) {
#       tryCatch(repo_to_img(x), error = function(e) '')
#     }, character(1))
#     images <- docker_img_ls()
#     img_exists <- imgnms %in% images[['repository']]
#     res <- tibble::as_tibble(list(pkg = modules, repo = repos,
#                                   docker_img = imgnms, img_exists = img_exists))
#   } else {
#     res <- tibble::as_tibble(list(pkg = modules, repo = repos))
#   }
#   res
# }

#' @name module_import
#' @title Import functions from a module
#' @description Import specific functions from an outsider module to the
#' Global Environment.
#' @param repo Module repo
#' @param fname Function name to import
#' @details If program is successfully removed from your system, TRUE is
#' returned else FALSE.
#' @example examples/module_install.R
#' @return Function
#' @export
#' @family user
module_import <- function(fname, repo) {
  # TODO: res <- image_install(pkgnm = pkgnm, tag = tag, pull = !manual)
  pkgnm <- pkgnm_guess(repo = repo)
  if (!pkgnm %in% utils::installed.packages()) {
    stop('Module ', char(repo), ' not found', call. = FALSE)
  }
  nmspc_get(x = fname, ns = pkgnm)
}
nmspc_get <- function(...) {
  utils::getFromNamespace(...)
}

#' @name module_help
#' @title Get help for outsider modules
#' @description Look up help files for specific outsider module functions or
#' whole modules.
#' @param repo Module repo
#' @param fname Function name
#' @example examples/module_install.R
#' @return NULL
#' @export
#' @family user
module_help <- function(repo, fname = NULL) {
  pkgnm <- pkgnm_guess(repo = repo)
  if (!pkgnm %in% utils::installed.packages()) {
    stop('Module ', char(repo), ' not found', call. = FALSE)
  }
  if (is.null(fname)) {
    hlp_get(package = (pkgnm))
  } else {
    hlp_get(package = (pkgnm), topic = (fname))
  }
}
hlp_get <- function(...) {
  utils::help(...)
}
