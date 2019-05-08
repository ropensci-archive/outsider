# Vars ----
# Auth ----
# Functions ----
#' @name gitlab_repo_search
#' @title Search for repository
#' @description Return gitlab API item for specific repository.
#' @param repo gitlab repo
#' @return data.frame
gitlab_repo_search <- function(repo) {
  stop('Not yet implemented')
}

#' @name gitlab_search
#' @title Search for outsider modules in GitLab
#' @description Returns GitLab API item results for outsider module search.
#' @return data.frame
gitlab_search <- function() {
  stop('Not yet implemented')
}

#' @name gitlab_module_details
#' @title Look up details of module(s) on GitLab
#' @description Return a tbl_df of information for outsider module(s).
#' If \code{repo} is NULL, will return details on all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @return tbl_df
#' @export
gitlab_module_details <- function(repo = NULL) {
  stop('Not yet implemented')
}
