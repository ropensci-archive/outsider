# TODO:
# -- outline development steps
# -- vignette: phylogenetic pipeline
# -- backdoor
# -- facilitate commands via file
# -- normalize paths: reduce to basename even if not current file
# -- should be able to provide unparsed R variables

devtools::load_all('.')

repo <- 'dombennett/om..bamm'
repo <- 'dombennett/om..hello.world'
repo <- 'dombennett/om..mafft'
repo <- 'dombennett/om..raxml'
repo <- 'dombennett/om..pyrate'

library(outsider)
.module_test(repo)

library(outsider)
module_install(repo)
module_help(repo = repo)
pyrate <- module_import(fname = 'PyRate', repo = repo)
pyrate()
module_uninstall(repo)
