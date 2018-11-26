# TODO:
# -- .docker_killall
# -- tests for container.methods
# -- tests for outsider.methods
# -- outline development steps
# -- vignette: phylogenetic pipeline
# -- repo: starter package

devtools::load_all('.')

repo <- 'dombennett/om..bamm'
repo <- 'dombennett/om..hello.world'
repo <- 'dombennett/om..mafft'
repo <- 'dombennett/om..raxml'
repo <- 'dombennett/om..pyrate'

library(outsider)
module_install(repo)
module_import(fname = 'hello_world', repo = repo)
