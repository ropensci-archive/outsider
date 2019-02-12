library(outsider)
wd <- file.path(tempdir(), 'results')
dir.create(wd)
arglist <- c('-a', 10, '-b', 'model2', '-wd', wd, '--unwanted')
# drop unwanted key:value pairs
(.arglist_parse(arglist = arglist, keyvals_to_drop = '-wd',
                normalise_paths = FALSE))
# drop unwanted argument values
(.arglist_parse(arglist = arglist, vals_to_drop = '--unwanted',
                normalise_paths = FALSE))
# make paths relative, necessary for Docker:
#   paths must be relative to the working directory in the container
(.arglist_parse(arglist = arglist, normalise_paths = TRUE))


# clean-up
unlink(wd, recursive = TRUE)
