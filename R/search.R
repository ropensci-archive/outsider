# Private ----
#' @name yaml_read
#' @title Safely read om.yaml
#' @description Return list of 'program' and 'details'.
#' @param url URL to repo
#' @return list
yaml_read <- function(url) {
  lines <- tryCatch(expr = {
    readLines(con = url)
  }, error = function(e) {
    NULL
  }, warning = function(e) {
    NULL
  })
  string <- paste(lines, collapse = "\n")
  res <- yaml::yaml.load(string = string, error.label = NULL)
  list('program' = res[['program']], 'details' = res[['details']])
}

# Public ----
#' @name module_search
#' @title Search for available outsider modules
#' @description Return a list of available outsider modules.
#' @param service Code-sharing service, e.g. GitHub
#' @return Character vector
#' @example examples/module_search.R
#' @export
module_search <- function(service = c('github', 'bitbucket', 'gitlab')) {
  service <- match.arg(service)
  res <- switch(service, github = github_search(), gitlab = gitlab_search(),
                bitbucket = bitbucket_search())
  res[['full_name']]
}

#' @name module_details
#' @title Look up details on module(s)
#' @description Return a tbl_df of information for outsider module(s) for a
#' given code-sharing service. If \code{repo} is NULL, will return details on
#' all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @param service Code-sharing service, e.g. GitHub
#' @return tbl_df
#' @example examples/module_search.R
#' @export
module_details <- function(repo = NULL, service = c('github', 'bitbucket',
                                                    'gitlab')) {
  service <- match.arg(service)
  switch(service, github = github_module_details(repo = repo),
         gitlab = gitlab_module_details(repo = repo),
         bitbucket = bitbucket_module_details(repo = repo))
}

# @name module_exists
# @title Does module exist?
# @description Does the module(s) exist as a valid outsider module? Repo
# must be a valid GitHub repository with an om.yaml and a passing
# build status.
# @param repo Module repo(s)
# @return Logical
# @example examples/module_search.R
# @export
# @family user
# module_exists <- function(repo) {
#   # TODO: om.yaml
#   vapply(X = repo, FUN = build_status, FUN.VALUE = logical(1))
# }
