#' @name is_docker_available
#' @title Check if Docker is available
#' @description Docker is required to run \code{outsider}. This function tests
#' whether Docker is available.
#' @return Logical
#' @family private
is_docker_available <- function() {
  res <- sys::exec_internal(cmd = 'docker', args = '--help')
  res[['status']] == 0
}

#' @name build_status
#' @title Look-up details on program
#' @description Is build passing? Returns either TRUE or FALSE.
#' @param repo GitHub repo
#' @return Logical
#' @family private
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
