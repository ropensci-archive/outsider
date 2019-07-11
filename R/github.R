# Vars ----
gh_url <- 'https://github.com'
gh_api_url <- 'https://api.github.com'
gh_search_repo_url <- paste0(gh_api_url, '/search/repositories')

# Functions ----
#' @name github_repo_search
#' @title Search for repository
#' @description Return GitHub API item for specific repository.
#' @param repo GitHub repo
#' @return data.frame
github_repo_search <- function(repo) {
  search_args <- paste0('?q=', repo, '&', 'Type=Repositories',
                        authtoken_get('&'))
  github_res <- jsonlite::fromJSON(paste0(gh_search_repo_url, search_args))
  if (github_res[['total_count']] == 0) {
    warning('No ', char(repo), ' found.', call. = FALSE)
    return(data.frame())
  }
  if (github_res[['total_count']] > 1) {
    warning('Too many possible matching repos for ', char(repo), '.',
            call. = FALSE)
    return(data.frame())
  }
  github_res[['items']]
}

#' @name github_search
#' @title Search for outsider modules in GitHub
#' @description Returns GitHub API item results for outsider module search.
#' @return data.frame
github_search <- function() {
  search_args <- paste0('?q=om..+in:name+outsider-module+in:description',
                        '&', 'Type=Repositories', authtoken_get('&'))
  github_res <- jsonlite::fromJSON(paste0(gh_search_repo_url, search_args))
  if (github_res[['incomplete_results']]) {
    warning('Not all repos discovered.')
  }
  github_res[['items']]
}

#' @name github_tags
#' @title Module tags from GitHub
#' @description Return tbl_df of module tags for a list of outsider
#' modules hosted on GitHub.
#' @param repos Character vector of outsider module repositories.
#' @return tbl_df
github_tags <- function(repos) {
  fetch <- function(repo) {
    api_url <- paste0(gh_api_url, '/repos/', repo, '/contents/inst/dockerfiles',
                      authtoken_get('?'))
    raw_df <- try(jsonlite::fromJSON(api_url), silent = TRUE)
    if (!inherits(raw_df, 'try-error')) {
      tag <- raw_df[ ,'name']
    } else {
      warning('Unable to fetch data from GitHub for ', char(repo))
      download_url <- tag <- ''
    }
    data.frame(repo = repo, tag = tag, stringsAsFactors = FALSE)
  }
  res <- lapply(X = repos, FUN = fetch)
  res <- do.call(what = rbind, args = res)
  tibble::as_tibble(x = res)
}
