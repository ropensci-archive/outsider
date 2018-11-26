# TODO: create proto-outsider module package skeleton
#' @name .travis_yaml
#' @title Generate travis file
#' @description Write .travis.yml to working directory.
#' @details All validated outsider modules must have a .travis.yml in their
#' repository. These .travis.yml must be generated using this function.
#' @param repo Repository
#' @param dir Directory in which to create .travis.yml
#' @return Logical
#' @export
#' @family developer
.travis_yaml <- function(repo, dir = getwd()) {
  url <- paste0('https://raw.githubusercontent.com/DomBennett/',
                'om..hello.world/master/.travis.yml')
  travis_text <- paste0(readLines(url), collapse = '\n')
  travis_text <- sub(pattern = 'DomBennett/om\\.\\.hello\\.world\\.\\.1\\.0',
                     replacement = repo, x = travis_text)
  write(x = travis_text, file = file.path(dir, '.travis.yml'))
  invisible(file.exists(file.path(dir, '.travis.yml')))
}
