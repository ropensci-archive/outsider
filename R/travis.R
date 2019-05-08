# Vars ----
travis_api_url <- 'https://api.travis-ci.org/repos/'

# Auth ----

#' @name travis_build_status
#' @title Check Travis build status
#' @description Is build passing on travis? Returns either TRUE or FALSE.
#' @param repo repo
#' @param service Code-sharing service, e.g. GitHub
#' @return Logical
travis_build_status <- function(repo, service = c('github', 'bitbucket',
                                                  'gitlab')) {
  res <- switch(service, github = github_repo_search(),
                bitbucket = bitbucket_repo_search(),
                gitlab = gitlab_repo_search())
  url <- paste0(travis_api_url, res[['full_name']], '.json')
  build_info <- try(expr = jsonlite::fromJSON(txt = url), silent = TRUE)
  !inherits(build_info, 'try-error') &&
    !is.null(build_info[["last_build_status"]]) &&
    build_info[["last_build_status"]] == 0
}
