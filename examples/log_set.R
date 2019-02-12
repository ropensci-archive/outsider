library(outsider)
# install and import
repo <- 'dombennett/om..hello.world'
module_install(repo = repo)
hello_world <- module_import(fname = 'hello_world', repo = repo)

# control the log stream
# send output to file
tmpfl <- tempfile()
log_set(log = 'program_out', val = tmpfl)
hello_world()
(readLines(con = tmpfl))
file.remove(tmpfl)
# send docker and program output to console
log_set(log = 'program_out', val = TRUE)
log_set(log = 'docker_out', val = TRUE)
hello_world()

# uninstall
rm(hello_world)
module_uninstall(repo = repo)