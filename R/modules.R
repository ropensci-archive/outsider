#' @name module_install
#' @title Install an outsider module
#' @description Install a module
#' @param repo Module repo
#' @return Logical
#' @export
module_install <- function(repo) {
  # if (!build_status(id = repo)) {
  #   mntnr <- sub(pattern = '/.*', replacement = '', x = repo)
  #   msg <- paste0('Sorry, it looks like ', char(repo), ' is not passing',
  #                 ' -- will not attempt to build on your system.',
  #                 'Try contacting ', char(mntnr), ' for help.')
  #   stop(msg)
  # }
  if (!is_docker_available()) {
    stop('Docker is not available. Have you installed it? And is it running?')
  }
  pkgnm <- .repo_to_pkgnm(repo)
  if (pkgnm %in% utils::installed.packages()) {
    stop(repo, ' already installed. Use `module_uninstall()` to remove',
         ' before installing again.', call. = FALSE)
  }
  dockerfile_url <- paste0('https://raw.githubusercontent.com/', repo,
                           '/master/Dockerfile')
  success <- .docker_build(img_id = .repo_to_img(repo), url = dockerfile_url)
  if (success) {
    suppressMessages(devtools::install_github(repo = repo))
  }
  invisible(pkgnm %in% utils::installed.packages())
}

#' @name module_uninstall
#' @title Uninstall and remove a module
#' @description Uninstall outsider module and removes it from your docker
#' @param repo Module repo
#' @details If program is successfully removed from your system, TRUE is
#' returned else FALSE.
#' @return Logical
#' @export
module_uninstall <- function(repo) {
  pkgnm <- .repo_to_pkgnm(repo)
  if (pkgnm %in% utils::installed.packages()) {
    .docker_img_rm(img_id = .repo_to_img(repo = repo))
    suppressMessages(utils::remove.packages(pkgs = pkgnm))
  }
  invisible(!pkgnm %in% utils::installed.packages())
}

#' @name module_import
#' @title Import functions from a module
#' @description Import specific functions from an outsider module to the
#' Global Environment.
#' @param repo Module repo
#' @param fname Function name to import
#' @details If program is successfully removed from your system, TRUE is
#' returned else FALSE.
#' @return Function
#' @export
module_import <- function(fname, repo) {
  pkgnm <- .repo_to_pkgnm(repo)
  utils::getFromNamespace(x = fname, ns = pkgnm)
}

#' @name module_help
#' @title Get help for outsider modules
#' @description Look up help files for specific outsider module functions or
#' whole modules.
#' @param repo Module repo
#' @param fname Function name
#' @return NULL
#' @export
module_help <- function(repo, fname = NULL) {
  pkgnm <- .repo_to_pkgnm(repo)
  if (!pkgnm %in% utils::installed.packages()) {
    stop('OM [', repo, '] not found', call. = FALSE)
  }
  if (is.null(fname)) {
    utils::help(package = (pkgnm))
  } else {
    utils::help(package = (pkgnm), topic = (fname))
  }
}

#' @name module_test
#' @title Test an outsider module
#' @description Ensure an outsider module builds and imports correctly and meets
#' certain criteria.
#' @param repo Module repo
#' @return Logical
#' @export
module_test <- function(repo) {
  on.exit(module_uninstall(repo = repo))
  res <- tryCatch(test_install(repo = repo), error = function(e) {
    message('Unable to install module! See error below:\n\n')
    stop(e, call. = FALSE)
  })
  res <- tryCatch(test_import(repo = repo), error = function(e) {
    message('Unable to import module functions! See error below:\n\n')
    stop(e, call. = FALSE)
  })
  res <- tryCatch(test_examples(repo = repo), error = function(e) {
    message('Unable to run module examples! See error below:\n\n')
    stop(e, call. = FALSE)
  })
  invisible(res)
}
