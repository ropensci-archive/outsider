# Vars ----
gl_url <- 'https://gitlab.com/'
gl_api_url <- paste0(gl_url, '/api/v4/')

# Functions ----
#' @name gitlab_repo_search
#' @title Search for repository
#' @description Return gitlab API item for specific repository.
#' @param repo gitlab repo
#' @return data.frame
gitlab_repo_search <- function(repo) {
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
  gitlab_res
}

#' @name gitlab_search
#' @title Search for outsider modules in GitLab
#' @description Returns GitLab API item results for outsider module search.
#' @return data.frame
gitlab_search <- function() {
  # https://stackoverflow.com/questions/31822385/how-to-use-gitlab-search-criteria
  search_url <- paste0(gl_api_url, 'search?scope=projects&search=om..',
                       authtoken_get(joiner = '&', service = 'gitlab'))
  gitlab_res <- jsonlite::fromJSON(search_url)
  # secondary filtering
  pull <- grepl(pattern = '^om\\.\\.', x = gitlab_res[['name']])
  pull <- grepl(pattern = "outsider-module", x = gitlab_res[['description']]) &
    pull
  gitlab_res[pull, ]
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

#' @name gitlab_module_details
#' @title Look up details of module(s) on GitLab
#' @description Return a tbl_df of information for outsider module(s).
#' If \code{repo} is NULL, will return details on all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @return tbl_df
#' @export
gitlab_module_details <- function(repo = NULL) {
  if (!is.null(repo)) {
    needed_clnms <- c('id', 'path_with_namespace', 'last_activity_at',
                      'star_count')
    gitlab_res <- lapply(X = repo, FUN = gitlab_repo_search)
    pull <- vapply(X = gitlab_res, FUN = function(x) {
      all(needed_clnms %in% colnames(x))
    }, FUN.VALUE = logical(1))
    gitlab_res <- gitlab_res[pull]
    gitlab_res <- lapply(X = gitlab_res, FUN = function(x) x[, needed_clnms])
    gitlab_res <- do.call(what = rbind, args = gitlab_res)
  } else {
    gitlab_res <- gitlab_search()
    repo <- gitlab_res[, 'path_with_namespace']
  }
  # look up yaml
  info <- yaml_read(repos = repo, service = 'gitlab')
  # look up version
  tags <- gitlab_tags(repo_ids = gitlab_res[['id']])
  info$versions <- vapply(X = unique(tags[['repo_id']]), FUN = function(x) {
    paste0(sort(tags[tags[['repo_id']] == x, 'tag'][[1]],
                decreasing = TRUE), collapse = ', ')
  }, FUN.VALUE = character(1))
  # add extra info
  index <- match(tolower(gitlab_res[, 'path_with_namespace']),
                 tolower(info[['repo']]))
  info[['updated_at']] <- as.POSIXct(gitlab_res[index, 'last_activity_at'],
                                     format = "%Y-%m-%dT%H:%M:%OSZ",
                                     timezone = 'UTC')
  info[['star_count']] <- gitlab_res[index, 'star_count']
  info[['url']] <- paste0('https://gitlab.com/', info[['repo']])
  # # order output
  info <- info[order(info[['program']], decreasing = TRUE), ]
  info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  info <- info[order(info[['star_count']], decreasing = TRUE), ]
  info
}
