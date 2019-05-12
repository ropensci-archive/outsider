#' @name pkgnm_guess
#' @title Guess package name
#' @description Return package name from a repo name.
#' @param repo Repository (e.g. "username/repo") associated with module
#' @param call_error Call error if no package found? Default, TRUE.
#' @details Raises error if no module discovered.
#' @return character(1)
pkgnm_guess <- function(repo, call_error = TRUE) {
  mdls <- modules_list()
  metas <- lapply(X = mdls, FUN = meta_get)
  # TODO: expand for more detection
  pull <- vapply(X = metas, FUN = function(x) {
    !is.null(x[['url']]) && grepl(pattern = repo, x = x[['url']],
                                  ignore.case = TRUE)
  }, FUN.VALUE = logical(1))
  if (sum(pull) == 1) {
    res <- mdls[pull]
  } else {
    if (call_error) {
      stop(paste0('No module associated with ', char(repo), ' could be found.'),
           call. = FALSE)
    }
    res <- NULL
  }
  res
}
