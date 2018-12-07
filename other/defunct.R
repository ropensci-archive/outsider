docker_push <- function(img, tag = 'latest') {
  args <- c('push', paste0(img, ':', tag))
  docker_cmd(args = args, std_out = log_get('docker_out'),
             std_err = log_get('docker_err'))
}

docker_login <- function(username) {
  psswrd_file <- tempfile()
  on.exit(file.remove(psswrd_file))
  msg <- paste0('Password for [', username, ']: ')
  write(x = getPass::getPass(msg = msg), file = psswrd_file)
  arglist <- c('login', '-u', username, '--password-stdin')
  res <- sys::exec_internal(cmd = 'docker', args = arglist,
                            std_in = psswrd_file)
  success <- res[['status']] == 0
  if (success) {
    cat_line('Successfully logged in as ', char(username))
  } else {
    cat_line('Login failed.')
  }
  invisible(success)
}

module_build <- function(wd, tag = 'latest') {
  cat_line(crayon::bold('Looking up package details ....'))
  pkgnm <- pkgnm_get(wd)
  cat_line('... Package: ', char(pkgnm))
  repo <- pkgnm_to_repo(pkgnm = pkgnm)
  cat_line('... GitHub repo: ', char(repo))
  cat_line(crayon::bold('Building Docker image ....'))
  cat_line('... Tag: ', char(tag))
  flpth <- file.path(wd, 'dockerfiles', tag, '.')
  img <- repo_to_img(repo)
  img_success <- docker_build(img = img, url_or_path = flpth, tag = tag)
  cat_line(crayon::bold('Building package ....'))
  pkg_success <- devtools::document(pkg = wd)
  pkg_success <- devtools::install(pkg = wd)
  invisible(img_success & pkg_success)
}

#' @name docker_killall
#' @title Attempt to kill all running docker containers
#' @description In the event a user loses track of the number of docker
#' containers they have created, this function will stop and remove all
#' active and inactive containers.
#' @details If you are running any non-outsider contianers, use this function
#' with caution.
#' @return Logical
#' @family private-docker
docker_killall <- function() {
  kill <- function(id) {
    exec <- function(id, action) {
      sys::exec_wait(cmd = 'docker', args = c(action, id), std_out = FALSE,
                     std_err = FALSE)
    }
    try(expr = {
      exec(id, 'stop')
      exec(id, 'rm')
    }, silent = TRUE)
  }
  is_docker_available()
  res <- sys::exec_internal(cmd = 'docker', args = c('ps', '-a'))
  if (res[['status']] == 0) {
    processes <- strsplit(x = rawToChar(res[['stdout']]),
                          split = '\n')[[1]][-1]
    processes <- strsplit(x = processes, split = "\\s{2,}")
    ps_ids <- vapply(X = processes, FUN = '[[', FUN.VALUE = character(1), 1)
    for (id in ps_ids) {
      kill(id)
    }
  }
  0
}
