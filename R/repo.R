#' @name pkgnm_guess
#' @title Guess package name
#' @description Return package name from a repo name.
#' @param repo Repository (e.g. "username/repo") or package name associated
#' with module
#' @param call_error Call error if no package found? Default, TRUE.
#' @details Raises error if no module discovered.
#' @return character(1)
pkgnm_guess <- function(repo, call_error = TRUE) {
  mdls <- modules_list()
  # Check names
  pull <- mdls == repo
  if (sum(pull) == 1) {
    return(mdls[pull])
  }
  # Check against repos
  metas <- lapply(X = mdls, FUN = meta_get)
  repos <- vapply(X = metas, FUN = function(x) {
    if (!is.null(x[['url']])) {
      res <- strsplit(x = x[['url']], split = '/')[[1]]
      res <- paste0(res[(length(res) - 1):length(res)], collapse = '/')
    } else {
      res <- x[['package']]
    }
    res
  }, FUN.VALUE = character(1))
  pull <- repos == repo
  if (sum(pull) == 1) {
    res <- mdls[pull]
  } else {
    if (call_error) {
      possibles <- repos[agrepl(pattern = repo, x = repos, max.distance = 0.1)]
      if (length(possibles) > 0) {
        possible_msg <- paste0('\nDid you mean ... ',
                               paste0(char(possibles), collapse = ' or '),
                               ' ... instead?')
      } else {
        possible_msg <- ''
      }
      stop(paste0('No module associated with ', char(repo),
                  ' could be found.', possible_msg), call. = FALSE)
    }
    res <- NULL
  }
  res
}
