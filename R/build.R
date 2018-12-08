# Developer build functions

# Private ----
#' @name test
#' @title Test a module
#' @description Test an outsider module by making sure it installs,
#' imports and its examples run correctly.
#' @param repo Repository
#' @return logical
#' @family private
test <- function(repo) {
  on.exit(module_uninstall(repo = repo))
  tags <- tags(repos = repo)
  for (i in seq_len(nrow(tags))) {
    tag <- tags[i, 'tag'][[1]]
    tag_msg <- paste0('Tag = ', char(tag))
    res <- tryCatch(install_test(repo = repo, tag = tag),
                    error = function(e) {
                      message(paste0('Unable to install module! ', tag_msg,
                                     ". See error below:\n\n"))
                      stop(e)
                    })
    res <- import_test(repo = repo)
    if (!res) {
      stop('Unable to import all module functions! ', tag_msg, call. = FALSE)
    }
    res <- examples_test(repo = repo)
    if (!res) {
      stop('Unable to run all module examples! ', tag_msg, call. = FALSE)
    }
  }
  invisible(res)
}

#' @name pkgdetails_get
#' @title Read the package description
#' @description Return a list of all package details based on a package's
#' DESCRIPTION file.
#' @param flpth Path to package
#' @return logical
#' @family private
pkgdetails_get <- function(flpth) {
  flpth <- file.path(flpth, 'DESCRIPTION')
  if (!file.exists(flpth)) {
    stop('Invalid R package path provided.', call. = FALSE)
  }
  lines <- readLines(con = flpth)
  lines <- strsplit(x = lines, split = ':')
  pull <- vapply(X = lines, FUN = length, FUN.VALUE = integer(1)) == 2
  lines <- lines[pull]
  nms <- vapply(X = lines, FUN = '[[', FUN.VALUE = character(1), 1)
  nms <- trimws(nms)
  vals <- vapply(X = lines, FUN = '[[', FUN.VALUE = character(1), 2)
  vals <- trimws(vals)
  names(vals) <- nms
  vals
}

#' @export
print.ids <- function(x) {
  for (i in seq_along(x)) {
    msg <- names(x)[[i]]
    if (length(x[[i]]) == 1) {
      cat_line(msg, ': ', char(x[[i]]))
    } else {
      cat_line(msg, ' ... ')
      for (j in seq_along(x[[i]])) {
        msg <- names(x[[i]])[[j]]
        cat_line('... ', msg, ': ', char(x[[i]][[j]]))
      }
    }
  }
}

#' @name templates_get
#' @title Retreive template files
#' @description Return template files for an outsider module.
#' @return character vector
#' @family private
templates_get <- function() {
  fls <- list.files(path = system.file("extdata", package = "outsider"),
                    pattern = 'template_')
  templates <- vector(mode = 'list', length = length(fls))
  destpths <- sub(pattern = 'template_', replacement = '', x = fls)
  destpths <- gsub(pattern = '_', replacement = .Platform$file.sep,
                   x = destpths)
  for (i in seq_along(fls)) {
    flpth <- system.file("extdata", fls[[i]], package = "outsider")
    templates[[i]] <- stringr::str_c(readLines(con = flpth), collapse = '\n')
  }
  names(templates) <- destpths
  templates
}

#' @name string_replace
#' @title Replace patterns in a string
#' @description For a given character string, replace patterns with values.
#' @return character
#' @family private
string_replace <- function(string, patterns, values) {
  for (i in seq_along(values)) {
    string <- stringr::str_replace_all(string = string,
                                       pattern = patterns[[i]],
                                       replacement = values[[i]])
  }
  string
}

#' @name file_create
#' @title Create file
#' @description Write x to a filepath. Forces creation of directories.
#' @param x Text for writing to file
#' @param flpth File path to be created
#' @return NULL
#' @family private
file_create <- function(x, flpth) {
  basefl <- basename(path = flpth)
  dirpth <- sub(pattern = basefl, replacement = '', x = flpth)
  suppressWarnings(dir.create(path = dirpth, recursive = TRUE))
  write(x = x, file = flpth)
}

# Public (hidden from general user) ----
#' @name .module_skeleton
#' @title Generate a skeleton for a module
#' @description Create all the base files and folders to kickstart the
#' development of a new outsider module.
#' @details Module developers must have a GitHub and Docker-Hub account.
#' For more detailed information, see online.
#' @param flpth File path to location of where module will be created, default
#' current working directory.
#' @param program_name Name of the command-line program
#' @param github_user Developer's username for GitHub
#' @param docker_user Developer's username for Docker
#' @return Logical
#' @export
#' @family developer
.module_skeleton <- function(program_name, github_user, docker_user,
                             flpth = getwd()) {
  r_version <- paste0(version[['major']], '.', version[['minor']])
  mdlnm <- paste0('om..', program_name)
  if (!dir.exists(file.path(flpth, mdlnm))) {
    dir.create(file.path(flpth, mdlnm))
  }
  package_name <- paste0(mdlnm, '..', github_user)
  repo <- paste0(github_user, '/', mdlnm)
  values <- mget(c('repo', 'package_name', 'r_version', 'docker_user',
                   'github_user', 'program_name'))
  patterns <- paste0('%', names(values), '%')
  templates <- templates_get()
  for (i in seq_along(templates)) {
    x <- string_replace(string = templates[[i]], patterns = patterns,
                        values = values)
    file_create(x = x, flpth = file.path(flpth, mdlnm, names(templates)[[i]]))
  }
  invisible(TRUE)
}

#' @name .module_travis
#' @title Generate Travis-CI file
#' @description Write .travis.yml to working directory.
#' @details All validated outsider modules must have a .travis.yml in their
#' repository. These .travis.yml must be generated using this function.
#' @param repo Repository
#' @param flpth Directory in which to create .travis.yml
#' @return Logical
#' @export
#' @family developer
.module_travis <- function(repo, flpth = getwd()) {
  url <- paste0('https://raw.githubusercontent.com/DomBennett/',
                'om..hello.world/master/.travis.yml')
  travis_text <- paste0(readLines(url), collapse = '\n')
  travis_text <- sub(pattern = 'DomBennett/om\\.\\.hello\\.world',
                     replacement = repo, x = travis_text, ignore.case = TRUE)
  write(x = travis_text, file = file.path(flpth, '.travis.yml'))
  invisible(file.exists(file.path(flpth, '.travis.yml')))
}

#' @name .module_identities
#' @title Return identities for a module
#' @description Returns a list of the identities (GitHub repo, Package name,
#' Docker images) for an outsider module. Works for modules in development.
#' Requires module to have a file path.
#' @param flpth File path to location of module
#' @return Logical
#' @export
#' @family developer
.module_identities <- function(flpth) {
  # TODO: come-up with better class name than "ids"
  res <- list()
  pkg_details <- pkgdetails_get(flpth = flpth)
  pkgnm <- pkg_details[['Package']]
  docker_user <- pkg_details[['Docker']]
  res[['R package name']] <- pkgnm
  repo <- pkgnm_to_repo(pkgnm = pkgnm)
  res[['GitHub repo']] <- repo
  dockerdirs <- list.files(file.path(flpth, 'dockerfiles'))
  img <- pkgnm_to_img(pkgnm = pkgnm, docker_user = docker_user)
  res[['Docker images']] <- paste0(img, ':', dockerdirs)
  structure(res, class = 'ids')
}

#' @name .module_check
#' @title Check names and structure of a module
#' @description Returns TRUE if all the names and structure of an outsider
#' module are correct.
#' @param flpth File path to location of module
#' @return Logical
#' @export
#' @family developer
.module_check <- function(flpth = NULL) {
  TRUE
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
#' @family developer
.module_test <- function(repo, verbose = FALSE) {
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
  res <- withr::with_options(new = temp_opts, code = test(repo = repo))
  invisible(res)
}
