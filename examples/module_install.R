library(outsider)
# simplest repo
repo <- 'dombennett/om..hello.world'
# if not installed, install
installed <- module_installed()
if (!repo %in% installed[['repo']]) module_install(repo)
# get help
module_help(repo = repo)
# import function
hello_world <- module_import(fname = 'hello_world', repo = repo)
# run function
hello_world()
