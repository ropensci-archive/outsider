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
  res <- sys::exec_internal(cmd = 'docker', args = 'ps')
  if (res[['status']] == 0) {
    ps <- strsplit(x = rawToChar(res[['stdout']]), split = '\n')[[1]][-1]
    return(length(ps))
  }
  0
}
