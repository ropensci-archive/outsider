# Private ----
authtoken_get <- function(joiner = c('?', '&'),
                          service = c('github', 'gitlab',
                                      'bitbucket')) {
  joiner <- match.arg(joiner)
  service <- match.arg(service)
  renvvar <- switch(service, github = "GITHUB_PAT",
                    gitlab = "GITLAB_PAT",
                    bitbucket = "BITBUCKET_PAT")
  tkn <- Sys.getenv(renvvar)
  if (nchar(tkn) > 0) {
    tkn_exp <- switch(service, github = 'access_token=',
                      gitlab = 'private_token=',
                      bitbucket = "")
    tkn <- paste0(joiner, tkn_exp, tkn)
  } else {
    tkn <- NULL
  }
  tkn
}

#' @name yaml_fetch
#' @title Safely fetch om.yaml
#' @description Return list of 'program' and 'details'.
#' @param url URL to repo
#' @return list
yaml_fetch <- function(url) {
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

#' @title Module YAML information
#' @description Return tbl_df of all YAML information of given outsider
#' module repos.
#' @param repos Character vector of outsider module repositories on GitHub,
#' GitLab or BitBucket.
#' @param service Code-sharing service. Character.
#' @return tbl_df
yaml_read <- function(repos, service = c('github', 'gitlab', 'bitbucket')) {
  extract <- function(x, i) {
    vapply(X = x, FUN = function(x, i) {
      res <- x[[i]]
      if (length(res) == 0) res <- ''
      res
    }, FUN.VALUE = character(1),
    i = i)
  }
  service <- match.arg(service)
  url <- switch(service, github = paste0('https://raw.githubusercontent.com/',
                                         repos, '/master/inst/om.yml'),
                gitlab = paste0('https://gitlab.com/', repos,
                                '/raw/master/inst/om.yml'),
                bitbucket = paste0('https://bitbucket.org/', repos,
                                   '/raw/master/inst/om.yml'))
  yaml <- lapply(X = url, FUN = yaml_fetch)
  prgms <- extract(x = yaml, i = 'program')
  dtls <- extract(x = yaml, i = 'details')
  tibble::as_tibble(x = list(repo = repos, program = prgms, details = dtls))
}

# Public ----
#' @name module_search
#' @title Search for available outsider modules
#' @description Return a list of available outsider modules. (Not possible for
#' BitBucket.)
#' @param service Code-sharing service, e.g. GitHub
#' @return Character vector
#' @example examples/module_search.R
#' @export
module_search <- function(service = c('github', 'gitlab')) {
  service <- match.arg(service)
  res <- switch(service, github = github_search(), gitlab = gitlab_search())
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
  repo_search <- switch(service, github = github_repo_search,
                        gitlab = gitlab_repo_search,
                        bitbucket = bitbucket_repo_search)
  service_search <- switch(service, github = github_search,
                           gitlab = gitlab_search,
                           bitbucket = bitbucket_search)
  tags_search <- switch(service, github = github_tags,
                        gitlab = gitlab_tags,
                        bitbucket = bitbucket_tags)
  url <- switch(service, github = 'https://github.com/',
                gitlab = 'https://gitlab.com/',
                bitbucket = 'https://bitbucket.org/')
  if (!is.null(repo)) {
    needed_clnms <- c('full_name', 'updated_at', 'watchers_count', 'url')
    if (service == 'gitlab') {
      needed_clnms <- c(needed_clnms, 'id')
    }
    res <- lapply(X = repo, FUN = repo_search)
    pull <- vapply(X = res, FUN = function(x) {
      all(needed_clnms %in% colnames(x))
    }, FUN.VALUE = logical(1))
    res <- res[pull]
    res <- lapply(X = res, FUN = function(x) x[, needed_clnms])
    res <- do.call(what = rbind, args = res)
  } else {
    res <- service_search()
    repo <- res[, 'full_name']
  }
  # look up yaml
  info <- yaml_read(repos = repo, service = service)
  # look up version(s)
  if (service == 'gitlab') {
    tags <- tags_search(repo_ids = res[['id']])
    tags[['repo']] <- res[['full_name']][match(tags[['repo_id']], res[['id']])]
  } else {
    tags <- tags_search(repos = repo)
  }
  info$versions <- vapply(X = unique(tags[['repo']]), FUN = function(x) {
    paste0(sort(tags[tags[['repo']] == x, 'tag'][[1]],
                decreasing = TRUE), collapse = ', ')
  }, FUN.VALUE = character(1))
  # add extra info
  index <- match(tolower(res[, 'full_name']), tolower(info[['repo']]))
  info[['updated_at']] <- as.POSIXct(res[index, 'updated_at'],
                                     format = "%Y-%m-%dT%H:%M:%OSZ",
                                     timezone = 'UTC')
  info[['star_count']] <- res[index, 'star_count']
  info[['url']] <- paste0(url, info[['repo']])
  # # order output
  info <- info[order(info[['program']], decreasing = TRUE), ]
  info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  info <- info[order(info[['star_count']], decreasing = TRUE), ]
  info
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
