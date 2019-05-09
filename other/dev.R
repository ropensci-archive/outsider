library(outsider)
repo <- 'dombennett/om..hello.world'
module_uninstall(repo = repo)
module_install(repo = repo, manual = TRUE)
hello_world <- module_import('hello_world', repo = 'om..hello.world')
hello_world()


# TODO:
# -- gitlab and bitbucket searching
# -- tidy up website
# -- expand documentation
