

recipe_install <- function() {
  # paths
  lbpth <- '/home/dom/Desktop/cmdr/lib'
  rcppth <- file.path('recipes', 'blast')
  # variables
  variables <- variables_get(rcppth = rcppth, lbpth = lbpth)
  # meta
  meta <- meta_get(rcppth = rcppth, variables = variables)
  # download
  download(url = meta[['source']][['url']], dr = variables[['tmpdr']])
  # build
  bash(scrpt_pth = file.path(rcppth, 'build.sh'), variables = variables)
  # test
  bash(scrpt_pth = file.path(rcppth, 'test.sh'), variables = variables)
  # clean up
  unlink(x = variables[['tmpdr']], recursive = TRUE, force = TRUE)
  dir.create(tempdir())
}


base_url <- 'https://api.github.com/search/repositories'
search_args <- '?q=om-+in:name+outsider-module+in:description&Type=Repositories'
res <- jsonlite::fromJSON(paste0(base_url, search_args))
repo <- paste0(res$items$owner$login, "/", res$items$name)
yaml_url <- paste0('https://raw.githubusercontent.com/', repo,
                   '/master/om.yml')
details <- yaml::read_yaml(yaml_url)
