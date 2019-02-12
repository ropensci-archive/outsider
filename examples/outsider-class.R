library(outsider)
# Set-up: install hello.world, ships with ubuntu
# we can make simple commands in bash via R
repo <- 'dombennett/om..hello.world'
# if not installed, install
installed <- module_installed()
if (!repo %in% installed[['repo']]) module_install(repo)

# Run echo
# create a outsider object that contains argument and Docker container details
otsdr <- outsider::.outsider_init(repo = repo, cmd = 'echo',
                                  arglist = c('hello world!'))
# check details
print(otsdr)
# run the command
# NOT RUN
# outsider::.run(otsdr)

# Send a file
# an existing outsider object can be modified
tmppth <- tempdir()
flpth <- file.path(tmppth, 'testfile')
write(x = 'hello from within a file!', file = flpth)
otsdr$files_to_send <- flpth
otsdr$cmd <- 'cat'
otsdr$arglist <- 'testfile'
# check details
print(otsdr)
# run the command
outsider::.run(otsdr)

# Return a file
# an existing outsider object can be modified
otsdr$files_to_send <- NULL
otsdr$cmd <- 'touch'
otsdr$arglist <- 'newfile'
otsdr$wd <- tmppth  # determines where created files are returned to
# check details
print(otsdr)
# run the command
outsider::.run(otsdr)
# check if 'newfile' exists in tempdir()
nwflpth <- file.path(tmppth, 'newfile')
(file.exists(nwflpth))

# Clean-up
rm(otsdr)
file.remove(flpth)
file.remove(nwflpth)
