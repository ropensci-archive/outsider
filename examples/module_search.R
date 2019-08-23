library(outsider)
# return table of ALL available modules on GitHub
# NOT RUN - takes too long
# (available_modules <- module_search())

# look-up specific modules
repo <- 'dombennett/om..goodbye.world'
(suppressWarnings(module_details(repo = repo))) # no module exists, expect warning
repo <- 'dombennett/om..hello.world'
(module_details(repo = repo))
