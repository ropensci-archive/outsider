# Vars ----
travis_api_url <- 'https://api.travis-ci.org/repos/'

# Auth ----

#' @name travis_build_status
#' @title Check Travis build status
#' @description Is build passing on travis? Returns either TRUE or FALSE.
#' @details For GitHub-based repositories only.
#' @param repo repo
#' @return Logical
travis_build_status <- function(repo) {
  res <- github_repo_search(repo = repo)
  url <- paste0(travis_api_url, res[['full_name']], '.json')
  build_info <- try(expr = jsonlite::fromJSON(txt = url), silent = TRUE)
  !inherits(build_info, 'try-error') &&
    !is.null(build_info[["last_build_status"]]) &&
    build_info[["last_build_status"]] == 0
}
