#' outsider
#'
#'
#'
#' @docType package
#' @name outsider
NULL

#' @name .outsider_class
#' @title Construct outsider object
#' @description Returns a outsider object. The outsider object describes a
#' outsider module's program and arguments. The object is generated every
#' time an outsider module program is called. It details the arguments of a
#' call, the command as well as the files to send to the docker container.
#' @details The outsider module runs a docker container that acts like a 
#' separate machine on the host computer. All the files necessary for the 
#' program to be run must be sent to the remote machine before the program
#' is called.
#' The arguments, wd and files_to_send can all be defined after the outsider
#' has been initiated using \code{otsdr$``} notation.
#' Once a outsider has been defined, the command can be run using
#' \code{.run(otsdr)}.
#' The \code{arglist}, \code{wd} or \code{files_to_send} do not need to be
#' defined for the outsider to be run.
#' @param repo Repository of the outsider module
#' @param cmd Command to be called in the container
#' @param arglist Arguments for command, character vector
#' @param wd Directory to which program generated files will be returned
#' @param files_to_send Files to be sent to container
#' @return A list of class \code{outsider} with the following items:
#' \item{repo}{Repository of the outsider module}
#' \item{pkgnm}{Package name of the outsider module}
#' \item{cmd}{Command to be called in the container}
#' \item{arglist}{Arguments for command, character vector}
#' \item{wd}{Directory to which program generated files will be returned}
#' \item{files_to_send}{Files to be sent to container}
#' \item{container}{Docker container object}
#' @export
.outsider_init <- function(repo, cmd = NA, arglist = NULL, wd = NULL,
                           files_to_send = NULL) {
  pkgnm <- .repo_to_pkgnm(repo = repo)
  container <- container_init(pkgnm = pkgnm)
  parts <- list(repo = repo, pkgnm = pkgnm, cmd = cmd, arglist = arglist,
                wd = wd, files_to_send = files_to_send, container = container)
  structure(parts, class = 'outsider')
}

#' @export
.run <- function(x, ...) {
  UseMethod('.run', x)
}

#' @name .run
#' @title Run an outsider module
#' @description Run an outsider module using the outsider object.
#' @param x outsider object
#' @return Logical
#' @export
#' @family developer
.run.outsider <- function(x) {
  if (is.na(x[['cmd']])) {
    stop('Command not set')
  }
  cntnr <- x[['cntnr']]
  success <- start(cntnr)
  on.exit(expr = {
    halt(x = cntnr)
    if (!success) {
      message(print(outsider))
    }
  })
  if (length(x[['files_to_send']]) > 0) {
    success <- copy(x = cntnr, send = x[['files_to_send']])
  }
  success <- .run(x = cntnr, cmd = x[['cmd']], args = x[['arglist']])
  if (length(x[['wd']]) > 0) {
    success <- copy(x = cntnr, rtrn = x[['wd']])
  }
  if (inherits(success, 'error')) {
    message('An error occurred in the following outsider ...')
    message(print(x))
    stop(success)
  }
  invisible(success)
}

#' @export
print.outsider <- function(x) {
  cat_line(cli::rule())
  cat_line(crayon::bold('Outsider module:'))
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
  cat_line('Container ID ', char(x[['container']][['cntnr_id']]))
  cat_line('Container status ', char(status(x[['container']])))
  cat_line(cli::rule())
}
