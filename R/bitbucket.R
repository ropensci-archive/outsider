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
  bitbucket_res <- try(expr = jsonlite::fromJSON(search_url), silent = TRUE)
  if (inherits(x = bitbucket_res, what = 'try-error')) {
    warning('Unable to download ', char(repo), call. = FALSE)
    return(data.frame())
  }
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
                    full_name = bitbucket_res$full_name,
                    description = bitbucket_res$description,
                    updated_at = bitbucket_res$updated_on,
                    watchers_count = length(bitbucket_res$links$watchers),
                    stringsAsFactors = FALSE)
  res
}

#' @name bitbucket_search
#' @title Search for outsider modules in bitbucket
#' @description Returns bitbucket API item results for outsider module search.
#' @details Function is NOT available. This is a stub for when BitBucket API
#' updates.
#' @param ... Arguments
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
    bitbucket_res <- try(expr = jsonlite::fromJSON(dockerfiles_url),
                         silent = TRUE)
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
