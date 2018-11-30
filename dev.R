# TODO:
# -- update current modules
# -- tests everything again
# -- outline development steps
# -- vignette: phylogenetic pipeline
# -- repo: starter package
# -- backdoor

devtools::load_all('.')

repo <- 'dombennett/om..bamm'
repo <- 'dombennett/om..hello.world'
repo <- 'dombennett/om..mafft'
repo <- 'dombennett/om..raxml'
repo <- 'dombennett/om..pyrate'

library(outsider)
module_test(repo)

library(outsider)
module_install(repo)
module_help(repo = repo)
pyrate <- module_import(fname = 'PyRate', repo = repo)
pyrate()
module_uninstall(repo)
