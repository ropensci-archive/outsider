# User friendly install and import functions

# Private ----
#' @name is_installed
#' @title Is module installed?
#' @description Return TRUE if module is installed.
#' @return logical
#' @family private
is_installed <- function(repo) {
  mdl_installed <- module_installed()
  repo %in% mdl_installed[['repo']]
}

#' @name install
#' @title Install module
#' @description Build/pull Docker image and install R package
#' @param repo GitHub repository name
#' @param tag Docker-Hub tag, e.g. 'latest'
#' @param dockerfile_url URL to Dockerfile
#' @return logical
#' @family private
install <- function(repo, tag, dockerfile_url = NULL) {
  success <- FALSE
  on.exit(expr = {
    if (!success) {
      module_uninstall(repo = repo)
    }
  })
  devtools::install_github(repo = repo, quiet = TRUE)
  if (is_installed(repo = repo)) {
    # Reminder:
    #     The docker image name is determined from the installed package.
    #     It requires the Docker username in DESCRIPTION.
    #     repo_to_img is the only function that requires this.
    #     repo always refers to the GitHub repo.
    img <- repo_to_img(repo)
    if (is.null(dockerfile_url)) {
      success <- docker_pull(img = img, tag = tag)
    } else {
      success <- docker_build(img = img, url_or_path = dockerfile_url,
                              tag = tag)
    }
  }
  invisible(success)
}

# Public ----
#' @name module_install
#' @title Install an outsider module
#' @description Install a module
#' @param repo Module repo, character.
#' @param tag Module version, default latest. Character.
#' @param manual Build the docker image? Default FALSE. Logical.
#' @return Logical
#' @export
#' @family user
module_install <- function(repo, tag = 'latest', manual = FALSE) {
  if (!is_running_on_travis() && !build_status(repo = repo)) {
    msg <- paste0('It looks like ', char(repo),
                  ' is not successfully passing its tests on GitHub.\n',
                  'The module might not build or function properly. ')
    warning(msg)
  }
  is_docker_available()
  if (is_installed(repo)) {
    stop(char(repo), ' already installed. Use ', func('module_uninstall'),
         ' to remove before installing again.', call. = FALSE)
  }
  tag_data <- tags(repos = repo)
  pull <- tag_data[['tag']] == tag
  if (sum(pull) != 1) {
    tags <- vapply(X = tag_data[['name']], FUN = char,
                   FUN.VALUE = character(1))
    stop('Invalid version provided for ', char(repo),
         "\nAvailable versions are: ", paste0(tags, collapse = ', '))
  }
  if (manual) {
    dockerfile_url <- as.character(tag_data[pull, 'url'])
    success <- install(repo = repo, tag = tag, dockerfile_url = dockerfile_url)
  } else {
    success <- install(repo = repo, tag = tag)
  }
  success
  
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
  if (is_installed(repo = repo)) {
    docker_img_rm(img = repo_to_img(repo = repo))
    suppressMessages(utils::remove.packages(pkgs = pkgnm))
  }
  invisible(!is_installed(repo = repo))
}

#' @name module_installed
#' @title Which outsider modules are installed?
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
