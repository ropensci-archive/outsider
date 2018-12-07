# URL functions

# Private ----
#' @name build_status
#' @title Look-up details on program
#' @description Is build passing? Returns either TRUE or FALSE.
#' @param repo GitHub repo
#' @return Logical
#' @family private-check
build_status <- function(repo) {
  # search via GitHub API
  base_url <- 'https://api.github.com/search/repositories'
  search_args <- paste0('?q=', repo, '&', 'Type=Repositories')
  github_res <- jsonlite::fromJSON(paste0(base_url, search_args))
  if (github_res[['total_count']] == 0) {
    warning('No ', char(repo), ' found.')
    return(FALSE)
  }
  if (github_res[['total_count']] > 1) {
    warning('Too many possible matching repos for ', char(repo), '.')
    return(FALSE)
  }
  url <- 'https://api.travis-ci.org/repos/'
  url <- paste0(url, github_res[['items']][['full_name']], '.json')
  build_info <- try(expr = jsonlite::fromJSON(txt = url), silent = TRUE)
  !inherits(build_info, 'try-error') && build_info[["last_build_status"]] == 0
}

#' @name module_yaml
#' @title Module YAML information
#' @description Return tbl_df of all YAML information of given outsider
#' module repos.
#' @param repos Character vector of outsider module repositories.
#' @return tbl_df
#' @family private-search
module_yaml <- function(repos) {
  extract <- function(x, i) {
    vapply(X = x, FUN = function(x, i) {
      res <- x[[i]]
      if (length(res) == 0) res <- ''
      res
    }, FUN.VALUE = character(1),
    i = i)
  }
  prgm_dtls <- vector(mode = 'list', length = length(repos))
  for (i in seq_along(repos)) {
    yaml_url <- paste0('https://raw.githubusercontent.com/', repos[[i]],
                       '/master/om.yml')
    success <- tryCatch(expr = {
      tmp <- yaml::read_yaml(yaml_url)
      TRUE
    }, error = function(e) {
      FALSE
    }, warning = function(e) {
      FALSE
    })
    if (!success) {
      next
    }
    prgm_dtls[[i]] <- tmp
  }
  prgms <- extract(x = prgm_dtls, i = 'program')
  dtls <- extract(x = prgm_dtls, i = 'details')
  tibble::as_tibble(x = list(repo = repos, program = prgms, details = dtls))
}

#' @name module_tags
#' @title Module tags
#' @description Return tbl_df of module tags for a list of outsider
#' modules.
#' @param repos Character vector of outsider module repositories.
#' @return tbl_df
#' @family private-search
module_tags <- function(repos) {
  downloadurl_get <- function(repo, name) {
    paste0('https://raw.githubusercontent.com/', repo,
           '/master/dockerfiles/', name, '/Dockerfile')
  }
  all_repo <- tags <- download_urls <- NULL
  for (repo in repos) {
    api_url <- paste0('https://api.github.com/repos/', repo,
                      '/contents/dockerfiles')
    raw_df <- try(jsonlite::fromJSON(api_url), silent = TRUE)
    if (!inherits(raw_df, 'try-error')) {
      tags <- c(tags, raw_df[ ,'name'])
      download_urls <- c(download_urls,
                         downloadurl_get(repo = repo,
                                         name = raw_df[ ,'name']))
      all_repo <- c(all_repo, rep(repo, nrow(raw_df)))
    }
  }
  tibble::as_tibble(x = list(repo = all_repo, tag = tags, url = download_urls))
}


# Public ----
#' @name module_search
#' @title Search for available outsider modules
#' @description Return a list of available outsider modules.
#' @return Character vector
#' @export
#' @family user
module_search <- function() {
  base_url <- 'https://api.github.com/search/repositories'
  search_args <- paste0('?q=om..+in:name+outsider-module+in:description',
                        '&', 'Type=Repositories')
  github_res <- jsonlite::fromJSON(paste0(base_url, search_args))
  if (github_res[['incomplete_results']]) {
    warning('Not all repos discovered.')
  }
  res <- github_res[['items']]
  res[['full_name']]
}

#' @name module_details
#' @title Look up details on module(s)
#' @description Return a tbl_df of information for outsider module(s).
#' @param repo Vector of one or more outsider module repositories
#' @return tbl_df
#' @export
#' @family user
module_details <- function(repo) {
  # look up yaml
  info <- module_yaml(repos = repo)
  # look up version
  tags <- module_tags(repos = repo)
  info <- info[info[['repo']] %in% tags[['repo']], ]
  info$versions <- vapply(X = unique(tags[['repo']]), FUN = function(x) {
    paste0(sort(as.character(tags[tags[['repo']] == x, 'tag']),
                decreasing = TRUE), collapse = ', ')
  }, FUN.VALUE = character(1))
  # add extra info
  # index <- match(srch[['full_name']], rownames(info))
  # info[['updated_at']] <- as.POSIXct(srch[['updated_at']][index],
  #                                    format = "%Y-%m-%dT%H:%M:%OSZ",
  #                                    timezone = 'UTC')
  # info[['watcher_count']] <- srch[['watchers_count']][index]
  # info[['url']] <- paste0('https://github.com/', rownames(info))
  # # order output
  # info <- info[order(info[['program']], decreasing = TRUE), ]
  # info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  # info <- info[order(info[['watcher_count']], decreasing = TRUE), ]
  info
}

#' @name module_exists
#' @title Does module exist?
#' @description Does the module(s) exist as a valid outsider module? Repo
#' must be a valid GitHub repository with an om.yaml and a passing
#' build status.
#' @param repo Module repo(s)
#' @return Logical
#' @export
#' @family user
module_exists <- function(repo) {
  # TODO: om.yaml
  vapply(X = repo, FUN = build_status, FUN.VALUE = logical(1))
}
