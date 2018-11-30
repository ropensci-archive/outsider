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
  pkgnm <- repo_to_pkgnm(repo)
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
  pkgnm <- repo_to_pkgnm(repo)
  if (!pkgnm %in% utils::installed.packages()) {
    stop('Module ', char(repo), ' not found', call. = FALSE)
  }
  if (is.null(fname)) {
    utils::help(package = (pkgnm))
  } else {
    utils::help(package = (pkgnm), topic = (fname))
  }
}

#' @name module_installed
#' @title What outsider modules are installed?
#' @description Returns tbl_df of details for all outsider modules
#' installed on the user's computer.
#' @return tbl_df
#' @export
#' @family user
module_installed <- function() {
  installed <- utils::installed.packages()
  modules <- installed[grepl(pattern = '^om\\.\\.', x = installed)]
  if (length(modules) == 0) {
    return(tibble::as_tibble(x = list()))
  }
  repos <- vapply(X = modules, FUN = pkgnm_to_repo, character(1))
  imgnms <- vapply(X = repos, FUN = repo_to_img, character(1))
  images <- docker_img_ls()
  img_exists <- imgnms %in% images[['repository']]
  tibble::as_tibble(list(pkg = modules, repo = repos, docker_img = imgnms,
                         img_exists = img_exists))
}
