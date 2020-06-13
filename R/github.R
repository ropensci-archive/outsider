# Vars ----
gh_api_url <- 'https://api.github.com'
gh_search_repo_url <- paste0(gh_api_url, '/search/repositories')

api_request <- function(url, warn = TRUE) {
  tkn <- Sys.getenv("GITHUB_PAT")
  h <- curl::new_handle()
  if (nchar(tkn) > 0)
  {
    # From Oct 2020, GitHub API requires token to be provided via curl header
    curl::handle_setheaders(h, "Authorization-token" = tkn)
  }
  req <- try(curl::curl_fetch_memory(url, handle = h), silent = TRUE)
  if (warn && inherits(req, 'try-error') || req$status_code != 200) {
    warning("Unable to make URL request for ", char(url))
  }
  req
}

# Functions ----
#' @name github_repo_search
#' @title Search for repository
#' @description Return GitHub API item for specific repository.
#' @param repo GitHub repo
#' @return data.frame
github_repo_search <- function(repo) {
  search_args <- paste0('?q=', repo, '&', 'Type=Repositories')
  req <- api_request(paste0(gh_search_repo_url, search_args))
  github_res <- jsonlite::fromJSON(rawToChar(req$content))
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
                        '&', 'Type=Repositories')
  req <- api_request(paste0(gh_search_repo_url, search_args))
  github_res <- jsonlite::fromJSON(rawToChar(req$content))
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
    api_url <- paste0(gh_api_url, '/repos/', repo, '/contents/inst/dockerfiles')
    req <- api_request(url = api_url, warn = FALSE)
    if (!inherits(req, 'try-error') && req$status_code == 200) {
      raw_df <- jsonlite::fromJSON(rawToChar(req$content))
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
