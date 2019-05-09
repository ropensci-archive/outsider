# Vars ----
gh_url <- 'https://github.com'
gh_api_url <- 'https://api.github.com'
gh_search_repo_url <- paste0(gh_api_url, '/search/repositories')
gh_raw_url <- 'https://raw.githubusercontent.com/'

# Auth ----
authtoken_get <- function(joiner = c('?', '&')) {
  joiner <- match.arg(joiner)
  tkn <- Sys.getenv("GITHUB_PAT")
  if (nchar(tkn) > 0) {
    tkn <- paste0(joiner, 'access_token=', tkn)
  } else {
    tkn <- NULL
  }
  tkn
}

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

#' @name github_yaml
#' @title Module YAML information
#' @description Return tbl_df of all YAML information of given outsider
#' module repos.
#' @param repos Character vector of outsider module repositories on GitHub.
#' @return tbl_df
github_yaml <- function(repos) {
  extract <- function(x, i) {
    vapply(X = x, FUN = function(x, i) {
      res <- x[[i]]
      if (length(res) == 0) res <- ''
      res
    }, FUN.VALUE = character(1),
    i = i)
  }
  url <- paste0(gh_raw_url, repos, '/master/inst/om.yml')
  yaml <- lapply(X = url, FUN = yaml_read)
  prgms <- extract(x = yaml, i = 'program')
  dtls <- extract(x = yaml, i = 'details')
  tibble::as_tibble(x = list(repo = repos, program = prgms, details = dtls))
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
      download_url <- paste0(gh_raw_url, repo, '/master/dockerfiles/',
                             raw_df[ ,'name'], '/Dockerfile')
    } else {
      warning('Unable to fetch data from GitHub for ', char(repo))
      download_url <- tag <- ''
    }
    data.frame(repo = repo, tag = tag, download_url = download_url,
               stringsAsFactors = FALSE)
  }
  res <- lapply(X = repos, FUN = fetch)
  res <- do.call(what = rbind, args = res)
  tibble::as_tibble(x = res)
}

#' @name github_module_details
#' @title Look up details of module(s) on GitHub
#' @description Return a tbl_df of information for outsider module(s).
#' If \code{repo} is NULL, will return details on all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @return tbl_df
#' @export
github_module_details <- function(repo = NULL) {
  needed_clnms <- c('full_name', 'updated_at', 'watchers_count', 'url')
  if (!is.null(repo)) {
    github_res <- lapply(X = repo, FUN = github_repo_search)
    pull <- vapply(X = github_res, FUN = function(x) {
      all(needed_clnms %in% colnames(x))
    }, FUN.VALUE = logical(1))
    github_res <- github_res[pull]
    github_res <- lapply(X = github_res, FUN = function(x) x[, needed_clnms])
    github_res <- do.call(what = rbind, args = github_res)
  } else {
    github_res <- github_search()
    repo <- github_res[, 'full_name']
  }
  # look up yaml
  info <- github_yaml(repos = repo)
  # look up version
  tags <- github_tags(repos = repo)
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
