#' @name available
#' @title Look up information on all available outsider modules
#' @description Return information on all available outsider modules
#' @return data.frame
#' @export
#' @family user
available <- function() {
  # search outsider modules
  srch <- om_search()
  om_details(repo = srch[['full_name']])
}

om_details <- function(repos) {
  # look up yaml
  info <- om_yaml(repos = repos)
  # look up version
  vrsns <- om_versions(repos = repos)
  info$versions <- vapply(X = repos, FUN = function(x) {
    paste0(sort(vrsns[vrsns[['repo']] == x, 'name'], decreasing = TRUE),
           collapse = ', ')
    }, FUN.VALUE = character(1))
  # add extra info
  index <- match(srch[['full_name']], rownames(info))
  info[['updated_at']] <- as.POSIXct(srch[['updated_at']][index],
                                     format = "%Y-%m-%dT%H:%M:%OSZ",
                                     timezone = 'UTC')
  info[['watcher_count']] <- srch[['watchers_count']][index]
  info[['url']] <- paste0('https://github.com/', rownames(info))
  # order output
  info <- info[order(info[['program']], decreasing = TRUE), ]
  info <- info[order(info[['updated_at']], decreasing = TRUE), ]
  info <- info[order(info[['watcher_count']], decreasing = TRUE), ]
  info
}

#' @name om_search
#' @title Search for outsider modules
#' @description Return list of all available outsider modules
#' @return list
#' @family private
om_search <- function() {
  base_url <- 'https://api.github.com/search/repositories'
  search_args <- paste0('?q=om..+in:name+outsider-module+in:description',
                        '&', 'Type=Repositories')
  github_res <- jsonlite::fromJSON(paste0(base_url, search_args))
  if (github_res[['incomplete_results']]) {
    warning('Not all repos discovered.')
  }
  github_res[['items']]
}

#' @name om_yaml
#' @title Module YAML information
#' @description Return data.frame of all YAML information of given outsider
#' module repos.
#' @param repos Character vector of outsider module repositories.
#' @return data.frame
#' @family private
om_yaml <- function(repos) {
  header <- c("program", "details")
  info <- as.data.frame(matrix(NA, ncol = 2, nrow = length(repos)))
  colnames(info) <- header
  rownames(info) <- repos
  for (repo in repos) {
    yaml_url <- paste0('https://raw.githubusercontent.com/', repo,
                        '/master/om.yml')
    success <- tryCatch(expr = {
      tmp <- yaml::read_yaml(yaml_url)
      all(c("program", "details") %in% names(tmp))
    }, error = function(e) {
      FALSE
    }, warning = function(e) {
      FALSE
    })
    if (!success) {
      next
    }
    tmp[vapply(tmp, is.null, logical(1))] <- ''
    for (h in header) {
      info[repo, h] <- tmp[[h]]
    }
  }
  info
}


om_versions <- function(repos) {
  res <- data.frame(repo = NA, name = NA, download_url = NA)
  for (repo in repos) {
    api_url <- paste0('https://api.github.com/repos/', repo,
                      '/contents/dockerfiles')
    raw_df <- jsonlite::fromJSON(api_url)
    raw_df <- raw_df[ ,c('name', 'download_url')]
    raw_df$repo <- repo
    res <- rbind(res, raw_df)
  }
  res <- res[-1, ]
  rownames(res) <- NULL
  res
}
