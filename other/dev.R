library(outsider)
repo <- 'dombennett/om..hello.world'
module_uninstall(repo = repo)
module_install(repo = repo, manual = TRUE)
hello_world <- module_import('hello_world', repo = 'om..hello.world')
hello_world()


# TODO:
# -- easier verbosity setting
# -- gitlab and bitbucket searching
# -- tidy up website
# -- move dockerfiles to inst
# -- check if docker is available on attach
