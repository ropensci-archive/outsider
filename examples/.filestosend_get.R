library(outsider)
# set-up: create wd and files to send
wd <- file.path(tempdir(), 'results')
dir.create(wd)
file1 <- file.path(wd, 'file1')
file.create(file1)
file2 <- file.path(wd, 'file2')
file.create(file2)


# identify files to be sent to container
arglist <- c('-in', file1, '-out', file2)
(.filestosend_get(arglist = arglist))
# works with -wd
arglist <- c('-in', 'file1', '-out', 'file2', '-wd', wd)
(.filestosend_get(arglist = arglist, wd = wd))


# clean-up
unlink(wd, recursive = TRUE)
