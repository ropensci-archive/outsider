
#' @name launcher_class
#' @title Construct launcher object
#' @description Returns a launcher object. The launcher object describes a
#' outsider module's program and arguments. The object is generated every
#' time an outsider module program is called. It details the arguments of a
#' call, the command as well as the files to send to the docker container.
#' @details The outsider module runs a docker container that acts like a 
#' separate machine on the host computer. All the files necessary for the 
#' program to be run must be sent to the remote machine before the program
#' is called.
#' @param repo Repository of the outsider module
#' @param cmd Command to be called in the container
#' @param arglist Arguments for command, character vector
#' @param wd Directory to which program generated files will be returned
#' @param files_to_send Files to be sent to container
#' @return Character vector
#' @export
launcher_class <- function(repo, cmd = NA, arglist = NULL, wd = NULL,
                           files_to_send = NULL) {
  pkgnm <- .repo_to_pkgnm(repo = repo)
  parts <- list(repo = repo, pkgnm = pkgnm, cmd = cmd, arglist = arglist,
                wd = wd, files_to_send = files_to_send)
  structure(parts, class = 'launcher')
}

#' @export
run <- function(x, ...) {
  UseMethod('run', x)
}

#' @export
run.launcher <- function(x) {
  if (is.na(x[['cmd']])) {
    stop('Command not set')
  }
  cntnr <- container_class(pkgnm = x[['pkgnm']])
  success <- start(cntnr)
  on.exit(expr = {
    halt(x = cntnr)
    if (!success) {
      message(print(launcher))
    }
    })
  if (length(x[['files_to_send']]) > 0) {
    success <- copy(x = cntnr, send = x[['files_to_send']])
  }
  success <- run(x = cntnr, cmd = x[['cmd']], args = x[['arglist']])
  if (length(x[['wd']]) > 0) {
    success <- copy(x = cntnr, rtrn = x[['wd']])
  }
  if (inherits(success, 'error')) {
    message('An error occurred in the following launcher ...')
    message(print(x))
    stop(success)
  }
  invisible(success)
}

#' @export
print.launcher <- function(x) {
  cat_line(cli::rule())
  cat_line(crayon::bold('Outsider module launcher:'))
  cat_line('Repo ', char(x[['repo']]))
  cat_line('Package ', char(x[['pkgnm']]))
  cat_line('Command ', char(x[['cmd']]))
  arglist <- lapply(X = x[['arglist']], FUN = function(x) {
    ifelse(is.numeric(x), stat(x), char(x))
  })
  # TODO: add column width
  cat_line('Args ', paste0(arglist, collapse = ', '))
  cat_line('Files to send ', paste0(x[['files_to_send']], collapse = ', '))
  cat_line('Working dir ', char(x[['wd']]))
  cat_line(cli::rule())
}
