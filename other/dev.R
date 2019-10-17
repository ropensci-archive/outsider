
devtools::load_all()

user_warn('om..hello.world')


library(outsider)
repo <- 'dombennett/om..hello.world'
module_uninstall(repo = repo)
module_install(repo = repo, manual = TRUE)
hello_world <- module_import('hello_world', repo = 'om..hello.world')
hello_world()


# TODO:
# -- tests
# -- update all current modules
# -- update website
# -- expand documentation
# -- appveyor
