#' @name log_set
#' @title Set log streams for console output
#' @description Set if and where to send the console streams of the outsider
#' modules.
#' @param log Output stream one of program_out, program_err, docker_out or
#' docker_err
#' @param val Either logcal, file or connection.
#' @details
#' See \code{\link[sys]{exec}}.
#' @return NULL
#' @export
#' @family user
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

#' @name log_get
#' @title Return log stream option
#' @description Return the log stream setting for a given stream. If the stream
#' is not set, the function will return TRUE (i.e. prints to console).
#' @return NULL
#' @family private
log_get <- function(log = c('program_out', 'program_err', 'docker_out',
                            'docker_err')) {
  res <- getOption(match.arg(log))
  if (is.null(res)) {
    res <- TRUE
  }
  res
}

#' @name default_log_set
#' @title Set default log streams
#' @description By default all streams are printed to console with the exception
#' of \code{docker_out}.
#' @return NULL
#' @family private
default_log_set <- function() {
  options(program_out = TRUE)
  options(program_err = TRUE)
  options(docker_out = FALSE)
  options(docker_err = TRUE)
}
