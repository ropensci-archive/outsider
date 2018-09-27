#' @name is_docker_available
#' @title Check if Docker is available
#' @description Docker is required to run \code{outsider}. This function tests
#' whether Docker is available.
#' @return Logical
#' @family check
is_docker_available <- function() {
  res <- sys::exec_internal(cmd = 'docker', args = '--help')
  res[['status']] == 0
}

#' @name build_status
#' @title Look-up details on program
#' @description Is build passing? Returns either TRUE or FALSE.
#' @param id Program ID
#' @return Logical
#' @family check
build_status <- function(id) {
  url <- 'https://api.travis-ci.org/repos/'
  url <- paste0(url, id, '.json')
  build_info <- try(expr = jsonlite::fromJSON(txt = url), silent = TRUE)
  !inherits(build_info, 'try-error') && build_info[["last_build_status"]] != 0
}
