library(outsider)
repo <- 'dombennett/om..hello.world'
module_uninstall(repo = repo)
module_install(repo = repo, manual = TRUE)
hello_world <- module_import('hello_world', repo = 'om..hello.world')
hello_world()


# TODO:
# -- easier verbosity setting
# -- gitlab and bitbucket searching

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
