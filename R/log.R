#' @name log_set
#' @title Set log streams for console output
#' @description Set if and where to send the console streams of the outsider
#' modules.
#' @param log Output stream one of 
#' @param val Either logcal, file or connection.
#' @param std_err if and where to direct child process STDERR.
#' See \code{\link[sys]{exec}}.
#' @details
#' See \code{\link[sys]{exec}}.
#' @return NULL
#' @export
log_set <- function(log, val) {
  if (log == 'program_out') {
    options(program_out = val)
  } else if (log == 'program_err') {
    options(program_err = val)
  } else if (log == 'docker_out') {
    options(docker_out = val)
  } else if (log == 'docker_err') {
    options(docker_err = val)
  } else {
    msg <- paste0('`log` must be one of: program_out, program_err,',
                  'docker_out or docker_err')
    stop(msg)
  }
}

default_log_set <- function() {
  options(program_out = TRUE)
  options(program_err = TRUE)
  options(docker_out = FALSE)
  options(docker_err = TRUE)
}

log_get <- function(log = c('program_out', 'program_err',
                            'docker_out', 'docker_err')) {
  res <- getOption(match.arg(log))
  if (is.null(res)) {
    res <- TRUE
  }
  res
}
