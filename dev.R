

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


