# Vars ----
bb_api_url <- 'https://api.bitbucket.org/2.0/'

# Functions ----
#' @name bitbucket_repo_search
#' @title Search for repository
#' @description Return bitbucket API item for specific repository.
#' @param repo bitbucket repo
#' @return data.frame
bitbucket_repo_search <- function(repo) {
  search_url <- paste0(bb_api_url, 'repositories/', repo)
  bitbucket_res <- jsonlite::fromJSON(search_url)
  if ('pagelen' %in% names(bitbucket_res)) {
    warning('Too many possible matching repos for ', char(repo), '.',
            call. = FALSE)
    return(data.frame())
  }
  if (length(bitbucket_res) == 0) {
    warning('No ', char(repo), ' found.', call. = FALSE)
    return(data.frame())
  }
  # parse into data.frame
  res <- data.frame(uuid = bitbucket_res$uuid,
                    repo = bitbucket_res$full_name,
                    description = bitbucket_res$description,
                    updated_on = bitbucket_res$updated_on,
                    watchers_count = length(bitbucket_res$links$watchers))
  res
}

#' @name bitbucket_search
#' @title Search for outsider modules in bitbucket
#' @description Returns bitbucket API item results for outsider module search.
#' @return data.frame
bitbucket_search <- function(...) {
  stop('BitBucket does not support search.', call. = FALSE)
  invisible(data.frame())
}

#' @name bitbucket_tags
#' @title Module tags from bitbucket
#' @description Return tbl_df of module tags for a list of outsider
#' modules hosted on bitbucket.
#' @param repos Character vector of outsider module repositories.
#' @return tbl_df
bitbucket_tags <- function(repos) {
  fetch <- function(repo) {
    dockerfiles_url <- paste0(bb_api_url, 'repositories/', repo,
                              '/src/master/inst/dockerfiles')
    bitbucket_res <- jsonlite::fromJSON(dockerfiles_url)
    if (!inherits(bitbucket_res, 'try-error')) {
      paths <- unname(vapply(X = bitbucket_res['values'], FUN = '[[',
                             FUN.VALUE = character(1), i = 1))
      tag <- sub(pattern = '^.*/', replacement = '', x = paths)
    } else {
      warning('Unable to fetch tag data from bitbucket for repo', char(repo))
      tag <- ''
    }
    data.frame(repo = repo, tag = tag, stringsAsFactors = FALSE)
  }
  res <- lapply(X = repos, FUN = fetch)
  res <- do.call(what = rbind, args = res)
  tibble::as_tibble(x = res)
}

#' @name bitbucket_module_details
#' @title Look up details of module(s) on BitBucket
#' @description Return a tbl_df of information for outsider module(s).
#' If \code{repo} is NULL, will return details on all available modules.
#' @param repo Vector of one or more outsider module repositories, default NULL.
#' @return tbl_df
#' @export
bitbucket_module_details <- function(repo = NULL) {
  needed_clnms <- c('full_name', 'updated_at', 'watchers_count', 'url')
  if (!is.null(repo)) {
    bitbucket_res <- lapply(X = repo, FUN = bitbucket_repo_search)
    pull <- vapply(X = bitbucket_res, FUN = function(x) {
      all(needed_clnms %in% colnames(x))
    }, FUN.VALUE = logical(1))
    bitbucket_res <- bitbucket_res[pull]
    bitbucket_res <- lapply(X = bitbucket_res,
                            FUN = function(x) x[, needed_clnms])
    bitbucket_res <- do.call(what = rbind, args = bitbucket_res)
  } else {
    stop('Search is not available for BitBucket.', call. = FALSE)
  }
  # look up yaml
  info <- yaml_read(repos = repo, service = 'bitbucket')
  # look up version
  tags <- bitbucket_tags(repos = repo)
  info$versions <- vapply(X = unique(tags[['repo']]), FUN = function(x) {
    paste0(sort(tags[tags[['repo']] == x, 'tag'][[1]],
                decreasing = TRUE), collapse = ', ')
  }, FUN.VALUE = character(1))
  # add extra info
  index <- match(tolower(bitbucket_res[, 'full_name']),
                 tolower(info[['repo']]))
  info[['updated_at']] <- as.POSIXct(bitbucket_res[index, 'updated_at'],
                                     format = "%Y-%m-%dT%H:%M:%OSZ",
                                     timezone = 'UTC')
  info[['watcher_count']] <- bitbucket_res[index, 'watchers_count']
  info[['url']] <- paste0('https://bitbucket.org/', info[['repo']])
  # # order output
  info <- info[order(info[['program']], decreasing = TRUE), ]
  info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  info <- info[order(info[['watcher_count']], decreasing = TRUE), ]
  info
}
