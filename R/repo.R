#' @name pkgnm_guess
#' @title Guess package name
#' @description Return package name from a repo name.
#' @param repo Repository (e.g. "username/repo") or package name associated
#' with module
#' @param call_error Call error if no package found? Default, TRUE.
#' @details Raises error if no module discovered.
#' @return character(1)
pkgnm_guess <- function(repo, call_error = TRUE) {
  check_and_return <- function(x, pull) {
    if (sum(pull) == 1) {
      return(mdls[pull])
    }
    # return possibles
    mdls[agrepl(pattern = repo, x = x, max.distance = 0.1)]
  }
  repo <- tolower(repo)
  mdls <- modules_list()
  # Check against package names
  possibles <- check_and_return(x = mdls, pull = mdls == repo)
  # Check against urls
  metas <- lapply(X = mdls, FUN = meta_get)
  urls <- vapply(X = metas, FUN = function(x) {
    res <- x[['url']]
    if (is.null(res)) {
      res <- ''
    }
    res
  }, FUN.VALUE = character(1))
  pull <- grepl(pattern = repo, x = urls)
  possibles <- c(check_and_return(x = urls, pull = pull), possibles)
  # Check against repos
  services <- c('github', 'gitlab', 'bitbucket')
  repos <- vapply(X = metas, FUN = function(x) {
    pull <- services %in% names(x)
    if (any(pull)) {
      service <- services[pull][[1]]
      res <- paste0(x[[service]], '/', x[['package']])
    } else {
      res <- x[['package']]
    }
    res
  }, FUN.VALUE = character(1))
  pull <- grepl(pattern = repo, x = repos)
  possibles <- c(check_and_return(x = repos, pull = pull), possibles)
  # call error and make suggestions
  if (call_error) {
    possibles <- unique(possibles)
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
  invisible(NULL)
}
