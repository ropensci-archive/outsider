#' outsider: Install and run programs, outside of R, inside of R
#'
#' The outsider package facilitates the installation and running of external
#' software by interfacing with docker (\url{https://www.docker.com/}).
#' External software are contained within mini-R-packages, called "outsider
#' modules" and can be installed directly to a user's computer through online
#' code-sharing services such as GitHub (\url{https://github.com/}). The
#' outsider package comes with a series of functions for identifying,
#' installing and importing these outsider modules.
#' 
#' For more information visit the outsider website
#' (\url{https://antonellilab.github.io/outsider/}).
#'
#' @docType package
#' @name outsider
#' @import outsider.base
NULL

#' @name verbosity_set
#' @title Set the verbosity of modules
#' @description Control console messages of running outsider modules. Allow
#' either the external program messages to run, the Docker messages or both.
#' @param show_program Show external program messages? Default TRUE.
#' @param show_docker Show docker messages? Default FALSE.
#' @details For more control see \code{\link[outsider.base]{log_set}}
#' @return data.frame
verbosity_set <- function(show_program = TRUE,
                          show_docker = FALSE) {
  log_set(log = 'program_out', val = show_program)
  log_set(log = 'program_err', val = show_program)
  log_set(log = 'docker_out', val = show_docker)
  log_set(log = 'docker_err', val = show_docker)
  invisible(TRUE)
}

.onAttach <- function(...) {
  v <- utils::packageVersion("outsider")
  msg <- paste0('outsider v ', v)
  msg_bar <- paste0(rep(x = '-', nchar(msg)), collapse = '')
  msg <- paste0(msg_bar, '\n', msg, '\n', msg_bar)
  # TODO: Maybe not here?
  msg <- paste0(msg,
                '\n- Secutiry notice: be sure of which modules you install')
  if (!is_docker_available(call_error = FALSE)) {
    # TODO: as a warning?
    msg <- paste0(msg, '\n- Warning: no Docker detected!')
  }
  verbosity_set()
  packageStartupMessage(msg)
}
