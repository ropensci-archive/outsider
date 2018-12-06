# docker_push <- function(img, tag = 'latest') {
#   args <- c('push', paste0(img, ':', tag))
#   docker_cmd(args = args, std_out = log_get('docker_out'),
#              std_err = log_get('docker_err'))
# }
# 
# docker_login <- function(username) {
#   psswrd_file <- tempfile()
#   on.exit(file.remove(psswrd_file))
#   msg <- paste0('Password for [', username, ']: ')
#   write(x = getPass::getPass(msg = msg), file = psswrd_file)
#   arglist <- c('login', '-u', username, '--password-stdin')
#   res <- sys::exec_internal(cmd = 'docker', args = arglist,
#                             std_in = psswrd_file)
#   success <- res[['status']] == 0
#   if (success) {
#     cat_line('Successfully logged in as ', char(username))
#   } else {
#     cat_line('Login failed.')
#   }
#   invisible(success)
# }
# 
# module_build <- function(wd, tag = 'latest') {
#   cat_line(crayon::bold('Looking up package details ....'))
#   pkgnm <- pkgnm_get(wd)
#   cat_line('... Package: ', char(pkgnm))
#   repo <- pkgnm_to_repo(pkgnm = pkgnm)
#   cat_line('... GitHub repo: ', char(repo))
#   cat_line(crayon::bold('Building Docker image ....'))
#   cat_line('... Tag: ', char(tag))
#   flpth <- file.path(wd, 'dockerfiles', tag, '.')
#   img <- repo_to_img(repo)
#   img_success <- docker_build(img = img, url_or_path = flpth, tag = tag)
#   cat_line(crayon::bold('Building package ....'))
#   pkg_success <- devtools::document(pkg = wd)
#   pkg_success <- devtools::install(pkg = wd)
#   invisible(img_success & pkg_success)
# }
