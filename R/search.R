#' @name module_yaml
#' @title Module YAML information
#' @description Return data.frame of all YAML information of given outsider
#' module repos.
#' @param repos Character vector of outsider module repositories.
#' @return data.frame
#' @family private-search
module_yaml <- function(repos) {
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

#' @name module_versions
#' @title Module versions
#' @description Return data.frame of module versions for a list of outsider
#' modules.
#' @param repos Character vector of outsider module repositories.
#' @return data.frame
#' @family private-search
module_versions <- function(repos) {
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
