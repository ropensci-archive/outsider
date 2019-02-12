library(outsider)
# build a skeleton package
flpth <- tempdir()
.module_skeleton(program_name = 'example', github_user = 'github_user',
                 docker_user = 'docker_user', flpth = flpth)
# look-up module user and program name/ids
# note: "om.." is added to the beginning of the program name
mdl_pth <- file.path(flpth, 'om..example')
(ids <- .module_identities(flpth = mdl_pth))
# generate .travis.yml
.module_travis(repo = ids$`GitHub repo`, flpth = mdl_pth)
cat(readLines(file.path(mdl_pth, '.travis.yml')), sep = '\n')
# check the package is formatted correctly
.module_check(flpth = mdl_pth)


# clean-up
unlink(x = mdl_pth, recursive = TRUE)
