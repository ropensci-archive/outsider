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

print.ids <- function(x) {
  for (i in seq_along(x)) {
    msg <- names(x)[[i]]
    if (length(x[[i]]) == 1) {
      cat_line(msg, ': ', char(x[[i]]))
    } else {
      cat_line(msg, '... ')
      for (j in seq_along(x[[i]])) {
        msg <- names(x[[i]][[j]])
        cat_line('... ', msg, ': ', char(x[[i]][[j]]))
      }
    }
  }
}

# Public ----
#' @name module_identities
#' @title Return identities for a module
#' @description Returns a list of the identities (GitHub repo, Package name,
#' Docker images) for an outsider module. Works for modules in development.
#' Requires module to have a file path.
#' @param flpth File path to location of module
#' @return Logical
#' @export
#' @family developer
module_identities <- function(flpth) {
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

#' @name module_check
#' @title Check names and structure of a module
#' @description Returns TRUE if all the names and structure of an outsider
#' module are correct.
#' @param flpth File path to location of module
#' @return Logical
#' @export
#' @family developer
module_check <- function(flpth = NULL) {
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

# Private ----
.module_test <- function(repo) {
  on.exit(module_uninstall(repo = repo))
  tags <- module_tags(repos = repo)
  for (i in seq_len(nrow(tags))) {
    tag <- tags[i, 'name']
    tag <- paste0('Tag = ', char(tags[i, 'name']))
    res <- tryCatch(install_test(repo = repo, tag = tag),
                    error = function(e) {
                      message(paste0('Unable to install module! ', tag,
                                     ". See error below:\n\n"))
                      stop(e)
                    })
    res <- import_test(repo = repo)
    if (!res) {
      stop('Unable to import all module functions! ', tag, call. = FALSE)
    }
    res <- examples_test(repo = repo)
    if (!res) {
      stop('Unable to run all module examples! ', tag, call. = FALSE)
    }
  }
  invisible(res)
}
