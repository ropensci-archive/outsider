# Vars ----
gl_url <- 'https://gitlab.com/'
gl_api_url <- paste0(gl_url, '/api/v4/')

# Hidden functions ----
gitlab_reformat <- function(api_res) {
  data.frame(id = api_res[['id']], full_name = api_res[['path_with_namespace']],
             updated_at = api_res[['last_activity_at']],
             star_count = api_res[['star_count']], stringsAsFactors = FALSE)
}
gitlab_token_check <- function() {
  if (!is.null(authtoken_get(service = 'gitlab'))) {
    warning('No GitLab token.')
  }
}

# Functions ----
#' @name gitlab_repo_search
#' @title Search for repository
#' @description Return gitlab API item for specific repository.
#' @param repo gitlab repo
#' @return data.frame
gitlab_repo_search <- function(repo) {
  gitlab_token_check()
  # drop username if present
  if (grepl(pattern = '/', x = repo)) {
    user_repo <- strsplit(x = repo, split = '/')[[1]]
    user <- user_repo[[1]]
    repo <- user_repo[[2]]
  } else {
    user <- NA
  }
  # search
  search_url <- paste0(gl_api_url, 'search?scope=projects&search=',
                       repo, authtoken_get(joiner = '&', service = 'gitlab'))
  gitlab_res <- jsonlite::fromJSON(search_url)
  if (!is.na(user)) {
    pull <- grepl(pattern = user, x = gitlab_res[['namespace']][['name']],
                  ignore.case = TRUE)
    gitlab_res <- gitlab_res[pull, ]
  }
  if (nrow(gitlab_res) == 0) {
    warning('No ', char(repo), ' found.', call. = FALSE)
    return(data.frame())
  }
  if (nrow(gitlab_res) > 1) {
    warning('Too many possible matching repos for ', char(repo), '.',
            call. = FALSE)
    return(data.frame())
  }
  gitlab_reformat(gitlab_res)
}

#' @name gitlab_search
#' @title Search for outsider modules in GitLab
#' @description Returns GitLab API item results for outsider module search.
#' @return data.frame
gitlab_search <- function() {
  gitlab_token_check()
  # https://stackoverflow.com/questions/31822385/how-to-use-gitlab-search-criteria
  search_url <- paste0(gl_api_url, 'search?scope=projects&search=om..',
                       authtoken_get(joiner = '&', service = 'gitlab'))
  gitlab_res <- jsonlite::fromJSON(search_url)
  # secondary filtering
  pull <- grepl(pattern = '^om\\.\\.', x = gitlab_res[['name']])
  pull <- grepl(pattern = "outsider-module", x = gitlab_res[['description']]) &
    pull
  gitlab_reformat(gitlab_res[pull, ])
}

#' @name gitlab_tags
#' @title Module tags from GitLab
#' @description Return tbl_df of module tags for a list of outsider
#' modules hosted on gitlab.
#' @param repos Character vector of outsider module repositories.
#' @return tbl_df
gitlab_tags <- function(repo_ids) {
  fetch <- function(repo_id) {
    tree_url <- paste0(gl_api_url, 'projects/', repo_ids, '/repository/tree',
                       authtoken_get(joiner = '?', service = 'gitlab'),
                       '&path=inst/dockerfiles&recursive=true')
    gitlab_res <- jsonlite::fromJSON(tree_url)
    if (!inherits(gitlab_res, 'try-error')) {
      paths <- gitlab_res[gitlab_res[['name']] == 'Dockerfile', 'path']
      paths <- sub(pattern = 'inst\\/dockerfiles\\/', replacement = '',
                   x = paths)
      tag <- sub(pattern = '/Dockerfile', replacement = '', x = paths)
    } else {
      warning('Unable to fetch tag data from GitLab for repo ID', char(repo_id))
      tag <- ''
    }
    data.frame(repo_id = repo_id, tag = tag, stringsAsFactors = FALSE)
  }
  res <- lapply(X = repo_ids, FUN = fetch)
  res <- do.call(what = rbind, args = res)
  tibble::as_tibble(x = res)
}
