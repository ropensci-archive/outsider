repo <- 'dombennett/om..revbayes'
repo <- 'dombennett/om..hello.world..0.0.0'
repo <- 'dombennett/om..mafft..7.407.wextensions'
repo <- 'dombennett/om..raxml..8.2.12.sse3.pthreads'
repo <- 'dombennett/om..pyrate'

library(outsider)
module_install(repo = repo)
module_help(repo = repo)
module_help(repo = repo, fname = 'hello_world')
hello_world <- module_import(fname = 'hello_world', repo = repo)
hello_world()
module_uninstall(repo = repo)


library(outsider)
repo <- 'dombennett/om..pyrate'
module_install(repo = repo)
module_help(repo = repo)
module_help(repo = repo, fname = 'pyrate')
pyrate <- module_import(fname = 'pyrate', repo = repo)
pyrate(help = TRUE)
module_uninstall(repo = repo)
















