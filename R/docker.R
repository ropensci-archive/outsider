#' @name docker_cmd
#' @title Run docker command
#' @description Runs a docker command with provided arguments
#' @param args Vector of arguments
#' @param std_out if and where to direct child process STDOUT.
#' See \code{\link[sys]{exec}}.
#' @param std_err if and where to direct child process STDERR.
#' See \code{\link[sys]{exec}}.
#' @return Logical
#' @family private-docker
docker_cmd <- function(args, std_out = TRUE, std_err = TRUE) {
  .is_docker_available()
  callr_args <- list(args, std_out, std_err)
  res <- callr::r(func = function(args, std_out, std_err) {
    sys::exec_wait(cmd = 'docker', args = args,
                   std_out = std_out, std_err = std_err) 
  }, args = callr_args, show = TRUE)
  res == 0
}

#' @name docker_img_rm
#' @title Remove docker image
#' @description Deletes docker image from system.
#' @param img_id Image ID
#' @return Logical
#' @family private-docker
docker_img_rm <- function(img_id) {
  args <- c('image', 'rm', img_id)
  docker_cmd(args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name docker_build
#' @title Build a docker image
#' @description Runs run \code{build} command.
#' @param img_id Image ID
#' @param url Dockerfile URL
#' @return Logical
#' @family private-docker
docker_build <- function(img_id, url) {
  args <- c('build', '-t', img_id, url)
  docker_cmd(args = args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name docker_cp
#' @title Copy files to and from container
#' @description Copy files to and from running Docker container
#' @details Container foldes are indicated with
#' \code{[container_id]:[filepath]}.
#' @param origin Origin filepath
#' @param dest Destination filepath
#' @return Logical
#' @family private-docker
docker_cp <- function(origin, dest) {
  args <- c('cp', origin, dest)
  docker_cmd(args = args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name docker_ps_count
#' @title Count docker processes
#' @description Count the number of running docker containers.
#' @details Use this to avoid creating multiple containers with the same ID.
#' @return Integer
#' @family private-docker
docker_ps_count <- function() {
  .is_docker_available()
  res <- sys::exec_internal(cmd = 'docker', args = 'ps')
  if (res[['status']] == 0) {
    ps <- strsplit(x = rawToChar(res[['stdout']]), split = '\n')[[1]][-1]
    return(length(ps))
  }
  0
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
  .is_docker_available()
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
