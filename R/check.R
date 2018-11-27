.is_docker_available <- function() {
  installed <- is_docker_installed()
  if (!installed) {
    message(paste0('Docker is not installed. ',
                   'Follow the installation instructions for your system:\n',
                   'https://docs.docker.com/'))
    running <- FALSE
  } else {
    running <- is_docker_running()
    if (!running) {
      message(paste0('Docker is not running. ', 'Start the docker program by ',
                     'looking it up in your applications/programs and ',
                     'opening it.'))
    }
  }
  avlbl <- installed & running
  if (!avlbl) {
    stop("Docker is not available.", call. = FALSE)
  }
}

#' @name is_docker_installed
#' @title Check if Docker is installed
#' @description Docker is required to run \code{outsider}. This function tests
#' whether Docker is installed.
#' @return Logical
#' @family private-check
is_docker_installed <- function() {
  res <- sys::exec_internal(cmd = 'docker', args = '--help')
  res[['status']] == 0
}

#' @name is_docker_running
#' @title Check if Docker is running
#' @description Docker is required to run \code{outsider}. This function tests
#' whether Docker is running.
#' @return Logical
#' @family private-check
is_docker_running <- function() {
  res <- tryCatch(expr = {
    res <- sys::exec_internal(cmd = 'docker', args = 'ps')
    res[['status']] == 0
    }, error = function(e) {
      FALSE
    })
  res
}

#' @name build_status
#' @title Look-up details on program
#' @description Is build passing? Returns either TRUE or FALSE.
#' @param repo GitHub repo
#' @return Logical
#' @family private-check
build_status <- function(repo) {
  # search via GitHub API
  base_url <- 'https://api.github.com/search/repositories'
  search_args <- paste0('?q=', repo, '&', 'Type=Repositories')
  github_res <- jsonlite::fromJSON(paste0(base_url, search_args))
  if (github_res[['total_count']] == 0) {
    warning('No ', char(repo), ' found.')
    return(FALSE)
  }
  if (github_res[['total_count']] > 1) {
    warning('Too many possible matching repos for ', char(repo), '.')
    return(FALSE)
  }
  url <- 'https://api.travis-ci.org/repos/'
  url <- paste0(url, github_res[['items']][['full_name']], '.json')
  build_info <- try(expr = jsonlite::fromJSON(txt = url), silent = TRUE)
  !inherits(build_info, 'try-error') && build_info[["last_build_status"]] == 0
}
