# Vars ----
# Auth ----
# Functions ----
#' @name bitbucket_repo_search
#' @title Search for repository
#' @description Return bitbucket API item for specific repository.
#' @param repo bitbucket repo
#' @return data.frame
bitbucket_repo_search <- function(repo) {
  stop('Not yet implemented')
}

#' @name bitbucket_search
#' @title Search for outsider modules in bitbucket
#' @description Returns bitbucket API item results for outsider module search.
#' @return data.frame
bitbucket_search <- function() {
  stop('Not yet implemented')
}

#' @name bitbucket_module_details
#' @title Look up details of module(s) on BitBucket
#' @description Return a tbl_df of information for outsider module(s).
#' If \code{repo} is NULL, will return details on all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @return tbl_df
#' @export
bitbucket_module_details <- function(repo = NULL) {
  stop('Not yet implemented')
}
