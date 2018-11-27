# Private ----
.module_install <- function(repo, dockerfile_url) {
  success <- docker_build(img_id = repo_to_img(repo), url = dockerfile_url)
  if (success) {
    devtools::install_github(repo = repo, quiet = TRUE)
  }
  invisible(module_installed(repo))
}

.module_test <- function(repo) {
  on.exit(module_uninstall(repo = repo))
  res <- tryCatch(install_test(repo = repo), error = function(e) {
    message('Unable to install module! See error below:\n\n')
    stop(e)
  })
  res <- import_test(repo = repo)
  if (!res) {
    stop('Unable to import all module functions!', call. = FALSE)
  }
  res <- examples_test(repo = repo)
  if (!res) {
    stop('Unable to run all module examples!', call. = FALSE)
  }
  invisible(res)
}

# Public ----
#' @name module_search
#' @title Search for available outsider modules
#' @description Return a list of available outsider modules.
#' @return Character vector
#' @export
#' @family user
module_search <- function() {
  base_url <- 'https://api.github.com/search/repositories'
  search_args <- paste0('?q=om..+in:name+outsider-module+in:description',
                        '&', 'Type=Repositories')
  github_res <- jsonlite::fromJSON(paste0(base_url, search_args))
  if (github_res[['incomplete_results']]) {
    warning('Not all repos discovered.')
  }
  github_res[['items']]
}

#' @name module_details
#' @title Look up details on module(s)
#' @description Return a data.frame of information for outsider module(s).
#' @param repo Vector of one or more outsider module repositories
#' @return data.frame
#' @export
#' @family user
module_details <- function(repo) {
  # look up yaml
  info <- module_yaml(repos = repo)
  # look up version
  vrsns <- module_versions(repos = repo)
  info$versions <- vapply(X = repos, FUN = function(x) {
    paste0(sort(vrsns[vrsns[['repo']] == x, 'name'], decreasing = TRUE),
           collapse = ', ')
  }, FUN.VALUE = character(1))
  # add extra info
  index <- match(srch[['full_name']], rownames(info))
  info[['updated_at']] <- as.POSIXct(srch[['updated_at']][index],
                                     format = "%Y-%m-%dT%H:%M:%OSZ",
                                     timezone = 'UTC')
  info[['watcher_count']] <- srch[['watchers_count']][index]
  info[['url']] <- paste0('https://github.com/', rownames(info))
  # order output
  info <- info[order(info[['program']], decreasing = TRUE), ]
  info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  info <- info[order(info[['watcher_count']], decreasing = TRUE), ]
  info
}

#' @name module_install
#' @title Install an outsider module
#' @description Install a module
#' @param repo Module repo
#' @param vrsn Module version, default latest
#' @return Logical
#' @export
#' @family user
module_install <- function(repo, vrsn = 'latest') {
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
  dockerfiles <- module_versions(repo = repo)
  pull <- dockerfiles[['name']] == vrsn
  if (sum(pull) != 1) {
    vrsns <- vapply(X = dockerfiles[['name']], FUN = char,
                    FUN.VALUE = character(1))
    stop('Invalid version provided for ', char(repo),
         "\nAvailable versions are: ", paste0(vrsns, collapse = ', '))
  }
  dockerfile_url <- dockerfiles[pull, 'download_url']
  .module_install(repo = repo, dockerfile_url = dockerfile_url)
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
    docker_img_rm(img_id = repo_to_img(repo = repo))
    suppressMessages(utils::remove.packages(pkgs = pkgnm))
  }
  invisible(!module_installed(repo = repo))
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
#' @param verbose Print docker and program info to console
#' @return Logical
#' @export
#' @family user
module_test <- function(repo, verbose = FALSE) {
  res <- FALSE
  on.exit(expr = {
    if (res) {
      celebrate()
    } else {
      comfort()
    }})
  if (verbose) {
    temp_opts <- list(program_out = TRUE, program_err = TRUE,
                      docker_out = TRUE, docker_err = TRUE)
  } else {
    temp_opts <- list(program_out = FALSE, program_err = FALSE,
                      docker_out = FALSE, docker_err = FALSE)
  }
  res <- withr::with_options(new = temp_opts, code = .module_test(repo = repo))
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
  pkgnm <- vapply(X = repo, FUN = repo_to_pkgnm, FUN.VALUE = character(1))
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
