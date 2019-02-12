library(outsider)
# simplest repo
repo <- 'dombennett/om..hello.world'
# install
module_install(repo = repo)
# get help
module_help(repo = repo)
# import function
hello_world <- module_import(fname = 'hello_world', repo = repo)
# run function
hello_world()
# uninstall
rm(hello_world)
module_uninstall(repo = repo)