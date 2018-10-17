#' @name module_install
#' @title Install an outsider module
#' @description Install a module
#' @param repo Module repo
#' @return Logical
#' @export
#' @family user
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
    devtools::install_github(repo = repo, quiet = TRUE)
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
#' @family user
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
#' @family user
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
#' @family user
module_help <- function(repo, fname = NULL) {
  pkgnm <- .repo_to_pkgnm(repo)
  if (!pkgnm %in% utils::installed.packages()) {
    stop('Outsider Module (OM) [', repo, '] not found', call. = FALSE)
  }
  if (is.null(fname)) {
    utils::help(package = (pkgnm))
  } else {
    utils::help(package = (pkgnm), topic = (fname))
  }
}

#' @name module_test
#' @title Test an outsider module
#' @description Ensure an outsider module builds, imports correctly and all
#' its functions successfully complete.
#' @details Success or fail, the module is uninstalled from the machine after
#' the test is run.
#' @param repo Module repo
#' @return Logical
#' @export
#' @family user
module_test <- function(repo) {
  on.exit(module_uninstall(repo = repo))
  res <- tryCatch(test_install(repo = repo), error = function(e) {
    message('Unable to install module! See error below:\n\n')
    stop(e)
  })
  res <- test_import(repo = repo)
  if (!res) {
    stop('Unable to import all module functions!', call. = FALSE)
  }
  res <- test_examples(repo = repo)
  if (!res) {
    stop('Unable to run all module examples!', call. = FALSE)
  }
  invisible(res)
}

#' @name module_installed
#' @title Is module installed?
#' @description Test whether an outsider module is installed.
#' @param repo Module repo(s)
#' @return Logical
#' @export
#' @family user
module_installed <- function(repo) {
  pkgnm <- vapply(X = repo, FUN = .repo_to_pkgnm, FUN.VALUE = character(1))
  pkgnm %in% utils::installed.packages()
}

#' @name module_exists
#' @title Does module exist?
#' @description Does the module(s) exist as a valid outsider module? Repo
#' must be a valid GitHub repository with an om.yaml and a passing
#' build status.
#' @param repo Module repo(s)
#' @return Logical
#' @export
#' @family user
module_exists <- function(repo) {
  # TODO: om.yaml
  vapply(X = repo, FUN = build_status, FUN.VALUE = logical(1))
}
