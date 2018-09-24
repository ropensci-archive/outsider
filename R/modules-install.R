modules_search <- function() {
  cat('Searching GitHub ....\n')
  base_url <- 'https://api.github.com/search/repositories'
  search_args <- '?q=om-+in:name+outsider-module+in:description&Type=Repositories'
  github_res <- jsonlite::fromJSON(paste0(base_url, search_args))
  if (github_res[['incomplete_results']]) {
    warning('Not all repos discovered.')
  }
  repos <- unname(vapply(X = github_res['items'], FUN = function(x) {
    paste0(x[['owner']][['login']], '/', x[['name']])
    }, FUN.VALUE = character(1)))
  details_get <- function(repo) {
    yaml_url <- paste0('https://raw.githubusercontent.com/', repo,
                       '/master/om.yml')
    success <- tryCatch(expr = {
      details <- yaml::read_yaml(yaml_url)
      all(names(details) %in% c("program", "flavour", "details"))
    }, error = function(e) {
      FALSE
    })
    if (success) {
      res <- data.frame(program = details[['program']],
                        flavour = details[['flavour']],
                        detail = details[['details']])
    } else {
      
    }
    res
  }
  
}