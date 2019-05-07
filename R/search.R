# Public ----
#' @name module_search
#' @title Search for available outsider modules
#' @description Return a list of available outsider modules.
#' @return Character vector
#' @example examples/module_search.R
#' @export
#' @family user
module_search <- function() {
  res <- all_search()
  res[['full_name']]
}

#' @name module_details
#' @title Look up details on module(s)
#' @description Return a tbl_df of information for outsider module(s).
#' If \code{repo} is NULL, will return details on all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @return tbl_df
#' @example examples/module_search.R
#' @export
#' @family user
module_details <- function(repo = NULL) {
  needed_clnms <- c('full_name', 'updated_at', 'watchers_count', 'url')
  if (!is.null(repo)) {
    github_res <- lapply(X = repo, FUN = repo_search)
    pull <- vapply(X = github_res, FUN = function(x) {
      all(needed_clnms %in% colnames(x))
      }, FUN.VALUE = logical(1))
    github_res <- github_res[pull]
    github_res <- lapply(X = github_res, FUN = function(x) x[, needed_clnms])
    github_res <- do.call(what = rbind, args = github_res)
  } else {
    github_res <- all_search()
    repo <- github_res[, 'full_name']
  }
  # look up yaml
  info <- yaml(repos = repo)
  # look up version
  tags <- tags(repos = repo)
  info$versions <- vapply(X = unique(tags[['repo']]), FUN = function(x) {
    paste0(sort(tags[tags[['repo']] == x, 'tag'][[1]],
                decreasing = TRUE), collapse = ', ')
  }, FUN.VALUE = character(1))
  # add extra info
  index <- match(tolower(github_res[, 'full_name']),
                 tolower(info[['repo']]))
  info[['updated_at']] <- as.POSIXct(github_res[index, 'updated_at'],
                                     format = "%Y-%m-%dT%H:%M:%OSZ",
                                     timezone = 'UTC')
  info[['watcher_count']] <- github_res[index, 'watchers_count']
  info[['url']] <- paste0('https://github.com/', info[['repo']])
  # # order output
  info <- info[order(info[['program']], decreasing = TRUE), ]
  info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  info <- info[order(info[['watcher_count']], decreasing = TRUE), ]
  info
}

#' @name module_exists
#' @title Does module exist?
#' @description Does the module(s) exist as a valid outsider module? Repo
#' must be a valid GitHub repository with an om.yaml and a passing
#' build status.
#' @param repo Module repo(s)
#' @return Logical
#' @example examples/module_search.R
#' @export
#' @family user
module_exists <- function(repo) {
  # TODO: om.yaml
  vapply(X = repo, FUN = build_status, FUN.VALUE = logical(1))
}
