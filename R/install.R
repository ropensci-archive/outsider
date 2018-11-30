# Public ----
#' @name module_install
#' @title Install an outsider module
#' @description Install a module
#' @param repo Module repo
#' @param tag Module version, default latest
#' @return Logical
#' @export
#' @family user
module_install <- function(repo, tag = 'latest') {
  if (!is_running_on_travis() && !build_status(repo = repo)) {
    msg <- paste0('It looks like ', char(repo),
                  ' is not successfully passing its tests on GitHub.\n',
                  'The module might not build or function properly. ')
    warning(msg)
  }
  .is_docker_available()
  if (module_installed(repo)) {
    stop(char(repo), ' already installed. Use ', func('module_uninstall'),
         ' to remove before installing again.', call. = FALSE)
  }
  tag_data <- module_tags(repos = repo)
  pull <- tag_data[['tag']] == tag
  if (sum(pull) != 1) {
    tags <- vapply(X = tag_data[['name']], FUN = char,
                   FUN.VALUE = character(1))
    stop('Invalid version provided for ', char(repo),
         "\nAvailable versions are: ", paste0(tags, collapse = ', '))
  }
  success <- docker_pull(img_id = repo_to_img(repo), tag = tag)
  if (success) {
    devtools::install_github(repo = repo, quiet = TRUE)
  }
  invisible(module_installed(repo))
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
  pkgnm <- repo_to_pkgnm(repo)
  if (pkgnm %in% devtools::loaded_packages()$package) {
    try(expr = devtools::unload(devtools::inst(pkgnm)), silent = TRUE)
  }
  if (module_installed(repo = repo)) {
    docker_img_rm(img = repo_to_img(repo = repo))
    suppressMessages(utils::remove.packages(pkgs = pkgnm))
  }
  invisible(!module_installed(repo = repo))
}
