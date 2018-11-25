# TODO: create a run roxygen doc template
#' @name .run
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param files_to_send Filepaths on host to send to module container.
#' @param dest Filepath on host computer for generated files to be returned
#' @param cmd Command to be run, e.g. echo, character
#' @param args Arguments for command, e.g. "hello world", character vector
#' @return Logical
#' @export
#' @family developer
.run <- function(pkgnm, cmd, args, files_to_send = NULL, dest = getwd()) {
  # launch container
  cntnr <- container_class(pkgnm = pkgnm)
  # close container after function has completed
  on.exit(halt(x = cntnr))
  # copy files_to_send to container
  copy(x = cntnr, send = files_to_send)
  # run command
  # (if command fails, safely shut the container down and send the error
  #  to console)
  success <- run_safe(cntnr = cntnr, cmd = cmd, args = args)
  # retrieve files
  copy(x = cntnr, rtrn = dest)
  if (inherits(success, 'error')) {
    stop(success)
  }
  invisible(success)
}

#' @name .run_nocopy
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param cmd Command to be run, e.g. echo, character
#' @param args Arguments for command, e.g. "hello world", character vector
#' @return Logical
#' @export
#' @family developer
.run_nocopy <- function(pkgnm, cmd, args) {
  cntnr <- container_class(pkgnm = pkgnm)
  on.exit(halt(x = cntnr))
  success <- run_safe(cntnr = cntnr, cmd = cmd, args = args)
  if (inherits(success, 'error')) {
    stop(success)
  }
  invisible(success)
}

#' @name .run_nosend
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param dest Filepath on host computer for generated files to be returned
#' @param cmd Command to be run, e.g. echo, character
#' @param args Arguments for command, e.g. "hello world", character vector
#' @return Logical
#' @export
#' @family developer
.run_nosend <- function(pkgnm, cmd, args, dest = getwd()) {
  cntnr <- container_class(pkgnm = pkgnm)
  on.exit(halt(x = cntnr))
  success <- run_safe(cntnr = cntnr, cmd = cmd, args = args)
  copy(x = cntnr, rtrn = dest)
  if (inherits(success, 'error')) {
    stop(success)
  }
  invisible(success)
}

#' @name .run_noreturn
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param cmd Command to be run, e.g. echo, character
#' @param args Arguments for command, e.g. "hello world", character vector
#' @param files_to_send Filepaths on host to send to module container.
#' @return Logical
#' @export
#' @family developer
.run_noreturn <- function(pkgnm, cmd, args, files_to_send = NULL) {
  cntnr <- container_class(pkgnm = pkgnm)
  on.exit(halt(x = cntnr))
  copy(x = cntnr, send = files_to_send)
  success <- run_safe(cntnr = cntnr, cmd = cmd, args = args)
  if (inherits(success, 'error')) {
    stop(success)
  }
  invisible(success)
}

run_safe <- function(cntnr, cmd, args) {
  success <- tryCatch(expr = {
    exec(x = cntnr, cmd, args)},
    error = function(e) {
      message('Unexpected error has occurred. Safely exiting...')
      e
    },
    interrupt = function(e) {
      message('User halted. Safely exiting...')
      FALSE
    })
  success
}