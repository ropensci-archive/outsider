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

patterns_get <- function(...) {
  res <- args_get()
  values <- vapply(X = res, FUN = eval, FUN.VALUE = character(1))
  patterns <- vapply(X = res, FUN = as.character, FUN.VALUE = character(1))
  data.frame(pattern = patterns, value = values)
}

string_replace <- function(string, patterns, values) {
  for (i in seq_along(values)) {
    string <- stringr::str_replace_all(string = string,
                                      pattern = patterns[[i]],
                                      replacement = values[[i]])
  }
  string
}

file_create <- function(x, flpth) {
  basefl <- basename(path = flpth)
  dirpth <- sub(pattern = basefl, replacement = '', x = flpth)
  suppressWarnings(dir.create(path = dirpth, recursive = TRUE))
  write(x = x, file = flpth)
}

#' @name module_skeleton
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
module_skeleton <- function(program_name, github_user, docker_user,
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
