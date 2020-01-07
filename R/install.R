
#' @name user_warn
#' @title Warn users on the dangers of outsider modules
#' @description Warn users on the dangers of installing an outsider module
#' whose origin is potentially unknown.
#' @details Prints additional info to screen based on module YAML file.
#' @param pkgnm Package name
#' @return Logical
user_warn <- function(pkgnm) {
  msg <- readLines(con = system.file('install_warning.txt',
                                     package = 'outsider'))
  ncols <- nchar(msg[[1]])
  bar <- paste0(rep('-', ncols), collapse = '')
  msg <- paste0(msg, collapse = '\n')
  msg <- paste0(msg, '\n Module information\n', bar, '\n')
  meta <- meta_get(pkgnm = pkgnm)
  for (nm in names(meta)) {
    msg <- paste0(msg, nm, ': ', meta[[nm]], '\n')
  }
  if ('github' %in% names(meta)) {
    is_passing <- travis_build_status(repo = paste0(meta[['github']], '/',
                                                    meta[['package']]))
    if (is_passing) {
      msg <- paste0(msg, 'Travis CI: Passing\n')
    } else {
      msg <- paste0(msg, 'Travis CI: Failing/Erroring\n')
    }
  }
  msg <- paste0(msg, bar)
  message(crayon::silver(msg))
  res <- tryCatch(expr = {
    rl(prompt = 'Enter any key to continue or press Esc to quit ')
    TRUE
  }, interrupt = function(e) {
    message('Halting installation ...')
    uninstall(pkgnm = pkgnm)
    FALSE
  })
  res
}
rl <- function(prompt) {
  readline(prompt = prompt)
}

# Public ----
#' @name module_install
#' @title Install an outsider module
#' @description Install a module through multiple different methods: via a code
#' sharing site such as GitHub, a URL, a git repository or local filepath.
#' The function will first install the R package and then build the Docker
#' image. Docker image version is determined by "tag". To avoid pulling
#' the image from DockerHub set "manual" to TRUE.
#' @details All installation options depend on the installation functions of
#' \code{remotes}. E.g. GitHub packages are installed with
#' \code{\link[remotes]{install_github}}. See these functions for more details
#' on the R package installation process.
#' @param repo Module repo, character.
#' @param url URL to downloadable compressed (zip, tar or bzipped/gzipped)
#' folder of a module, character.
#' @param git URL to git repository
#' @param filepath Filepath to uncompressed directory of module, character.
#' @param service Code-sharing service. Character.
#' @param tag Module version, default latest. Character.
#' @param manual Build the docker image? Default FALSE. Logical.
#' @param verbose Be verbose? Default FALSE.
#' @param force Ignore warnings and install anyway? Default FALSE.
#' @param update Update dependent R packages? 
#' @return Logical
#' @example examples/module_install.R
#' @export
module_install <- function(repo = NULL, url = NULL, filepath = NULL, git = NULL,
                           service = c('github', 'bitbucket', 'gitlab'),
                           tag = 'latest', manual = FALSE,
                           verbose = FALSE, force = FALSE,
                           update = c("default", "ask", "always", "never")) {
  res <- FALSE
  is_docker_available()
  if (length(c(repo, url, git, filepath)) != 1) {
    msg <- paste0('Must provide just 1 variable to either ', char('repo'),
                  ', ', char('url'), ' or ', char('filepath'))
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
  if (!is.null(git)) {
    pkgnm <- remotes::install_git(url = git, force = TRUE, quiet = !verbose,
                                  reload = TRUE, build = FALSE)
  }
  if (!is.null(filepath)) {
    pkgnm <- remotes::install_local(path = filepath, force = TRUE,
                                    quiet = !verbose, reload = TRUE,
                                    build = FALSE)
  }
  if (!force) {
    if (!user_warn(pkgnm = pkgnm)) {
      return(invisible(FALSE))
    }
  }
  res <- image_install(pkgnm = pkgnm, tag = tag, pull = !manual)
  invisible(res)
}

#' @name module_functions
#' @title List the functions associated with a module
#' @description Return a vector of functions that can be imported from the
#' module.
#' @param repo Module repo
#' @example examples/module_install.R
#' @return character
#' @export
#' @family public
module_functions <- function(repo) {
  ls(suppressMessages(loadNamespace(pkgnm_guess(repo = repo))))
}

#' @name is_module_installed
#' @title Is module installed?
#' @description Check if a module is installed on your system.
#' @param repo Module repo
#' @details Searches for \code{repo} among installed outsider modules. Returns
#' TRUE if found, else FALSE.
#' @example examples/module_install.R
#' @return Logical
#' @export
#' @family public
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
#' @family public
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
#' @family public
module_installed <- function() {
  fetch <- function(x, i) {
    res <- x[[i]]
    if (is.null(res)) {
      res <- ''
    }
    res
  }
  mdls <- modules_list()
  if (length(mdls) == 0) {
    return(tibble::as_tibble(x = list()))
  }
  res <- data.frame(package = mdls, image = NA, tag = NA, program = NA,
                    url = NA, image_created = NA, image_id = NA)
  meta <- lapply(X = mdls, FUN = meta_get)
  res[['image']] <- vapply(X = meta, FUN = fetch, i = 'image',
                           FUN.VALUE = character(1))
  res[['url']] <- vapply(X = meta, FUN = fetch, i = 'url',
                         FUN.VALUE = character(1))
  res[['program']] <- vapply(X = meta, FUN = fetch, i = 'program',
                             FUN.VALUE = character(1))
  avl_imgs <- docker_img_ls()
  avl_imgs <- avl_imgs[avl_imgs[['repository']] %in% res[['image']], ]
  pull <- match(avl_imgs[['repository']], res[['image']])
  res[['tag']][pull] <- avl_imgs[['tag']]
  res[['image_created']][pull] <- avl_imgs[['created']]
  res[['image_id']][pull] <- avl_imgs[['image_id']]
  res <- tibble::as_tibble(res)
  res
}

#' @name module_import
#' @title Import functions from a module
#' @description Import specific functions from an outsider module to the
#' Global Environment.
#' @param repo Module repo
#' @param fname Function name to import
#' @example examples/module_install.R
#' @return Function
#' @export
#' @family public
module_import <- function(fname, repo) {
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
#' @family public
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
