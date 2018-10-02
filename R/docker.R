#' @name .docker_cmd
#' @title Run docker command
#' @description Runs a docker command with provided arguments
#' @param args Vector of arguments
#' @param std_out if and where to direct child process STDOUT.
#' See \code{\link[sys]{exec}}.
#' @param std_err if and where to direct child process STDERR.
#' See \code{\link[sys]{exec}}.
#' @return Logical
#' @export
.docker_cmd <- function(args, std_out = TRUE, std_err = TRUE) {
  res <- sys::exec_wait(cmd = 'docker', args = args, std_out = std_out,
                        std_err = std_err)
  res == 0
}

#' @name .docker_img_rm
#' @title Remove docker image
#' @description Deletes docker image from system.
#' @param img_id Image ID
#' @return Logical
#' @export
.docker_img_rm <- function(img_id) {
  args <- c('image', 'rm', img_id)
  .docker_cmd(args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name .docker_build
#' @title Build a docker image
#' @description Runs run \code{build} command.
#' @param img_id Image ID
#' @param url Dockerfile URL
#' @return Logical
#' @export
.docker_build <- function(img_id, url) {
  args <- c('build', '-t', img_id, url)
  .docker_cmd(args = args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name .docker_start
#' @title Start a docker container
#' @description Runs run \code{run} command on a docker image.
#' @param cntnr_id Container ID
#' @param img_id Image ID
#' @return Logical
#' @export
.docker_start <- function(cntnr_id, img_id) {
  args <- c('run', '-t', '-d', '--name', cntnr_id, img_id)
  .docker_cmd(args = args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name .docker_stop
#' @title Stop and delete a docker container
#' @description Runs run \code{stop} and \code{rm} commands on running docker
#' containers.
#' @param cntnr_id Container ID
#' @return Logical
#' @export
.docker_stop <- function(cntnr_id) {
  args1 <- c('stop', cntnr_id)
  res1 <- .docker_cmd(args = args1, std_out = log_get('docker_out'),
                      std_err = log_get('docker_err'))
  args2 <- c('rm', cntnr_id)
  res2 <- .docker_cmd(args = args2, std_out = log_get('docker_out'),
                      std_err = log_get('docker_err'))
  res1 & res2
}

#' @name .docker_exec
#' @title Execute in a docker container
#' @description Pass commands to a running docker container with the \code{exec}
#' command.
#' @param cntnr_id Container ID
#' @param ... Command and arguments for container.
#' @return Logical
#' @export
.docker_exec <- function(cntnr_id, ...) {
  args <- c('exec', cntnr_id, ...)
  .docker_cmd(args, std_out = log_get('program_out'),
              std_err = log_get('program_err'))
}

#' @name .docker_cp
#' @title Copy files to and from container
#' @description Copy files to and from running Docker container
#' @details Container foldes are indicated with
#' \code{[container_id]:[filepath]}.
#' @return Logical
#' @export
.docker_cp <- function(origin, dest) {
  args <- c('cp', origin, dest)
  .docker_cmd(args = args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name .docker_ps_count
#' @title Count docker processes
#' @description Count the number of running docker containers.
#' @details Use this to avoid creating multiple containers with the same ID.
#' @return Integer
#' @export
.docker_ps_count <- function() {
  res <- sys::exec_internal(cmd = 'docker', args = 'ps')
  if (res[['status']] == 0) {
    ps <- strsplit(x = rawToChar(res[['stdout']]), split = '\n')[[1]][-1]
    return(length(ps))
  }
  0
}
