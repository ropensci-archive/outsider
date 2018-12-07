# Functions that interact directly with Docker

# Checks ----
#' @name is_docker_available
#' @title Check if Docker is installed and running
#' @description Raises an error if docker is not available.
#' @return NULL
#' @family private-check
is_docker_available <- function() {
  installed <- is_docker_installed()
  if (!installed) {
    message(paste0('Docker is not installed. ',
                   'Follow the installation instructions for your system:\n',
                   'https://docs.docker.com/'))
    running <- FALSE
  } else {
    running <- is_docker_running()
    if (!running) {
      message(paste0('Docker is not running. ', 'Start the docker program by ',
                     'looking it up in your applications/programs and ',
                     'opening it.'))
    }
  }
  avlbl <- installed & running
  if (!avlbl) {
    stop("Docker is not available.", call. = FALSE)
  }
  invisible(NULL)
}

#' @name is_docker_installed
#' @title Check if Docker is installed
#' @description Docker is required to run \code{outsider}. This function tests
#' whether Docker is installed.
#' @return Logical
#' @family private-check
is_docker_installed <- function() {
  success <- tryCatch(expr = {
    res <- sys::exec_internal(cmd = 'docker', args = '--help')
    res[['status']] == 0
    }, error = function(e) {
      FALSE
    })
  success
}

#' @name is_docker_running
#' @title Check if Docker is running
#' @description Docker is required to run \code{outsider}. This function tests
#' whether Docker is running.
#' @return Logical
#' @family private-check
is_docker_running <- function() {
  success <- tryCatch(expr = {
    res <- sys::exec_internal(cmd = 'docker', args = 'ps')
    res[['status']] == 0
  }, error = function(e) {
    FALSE
  })
  success
}

# Base function ----
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
  is_docker_available()
  callr_args <- list(args, std_out, std_err)
  res <- callr::r(func = function(args, std_out, std_err) {
    sys::exec_wait(cmd = 'docker', args = args,
                   std_out = std_out, std_err = std_err) 
  }, args = callr_args, show = TRUE)
  res == 0
}

# Derivatives ----
#' @name docker_img_rm
#' @title Remove docker image
#' @description Deletes docker image from system.
#' @param img Image name
#' @return Logical
#' @family private-docker
docker_img_rm <- function(img) {
  args <- c('image', 'rm', img)
  docker_cmd(args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

#' @name docker_pull
#' @title Pull an image from DockerHub.
#' @description Speeds up outsider module installation by downloading compiled
#' images.
#' @param img Image name
#' @return Logical
#' @family private-docker
docker_pull <- function(img, tag = 'latest') {
  args <- c('pull', paste0(img, ':', tag))
  docker_cmd(args = args, std_out = log_get('docker_out'),
             std_err = log_get('docker_err'))
}

#' @name docker_build
#' @title Build a docker image
#' @description Runs run \code{build} command.
#' @param img Image name
#' @param url_or_path Dockerfile URL
#' @param tag Docker tag, default 'latest'
#' @return Logical
#' @family private-docker
docker_build <- function(img, url_or_path, tag = 'latest') {
  args <- c('build', '-t', paste0(img, ':', tag), url_or_path)
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

# Special ----
#' @name docker_ps_count
#' @title Count docker processes
#' @description Count the number of running docker containers.
#' @details Use this to avoid creating multiple containers with the same ID.
#' @return Integer
#' @family private-docker
docker_ps_count <- function() {
  is_docker_available()
  res <- sys::exec_internal(cmd = 'docker', args = 'ps')
  if (res[['status']] == 0) {
    ps <- strsplit(x = rawToChar(res[['stdout']]), split = '\n')[[1]][-1]
    return(length(ps))
  }
  0
}

#' @name docker_img_ls
#' @title List the number of installed images
#' @description Return a table of all the available Docker images.
#' @return tibble
#' @family private-docker
docker_img_ls <- function() {
  res <- sys::exec_internal(cmd = 'docker', args = c('image', 'ls'))
  if (res[['status']] == 0) {
    images <- strsplit(x = rawToChar(res[['stdout']]), split = '\n')[[1]]
    images <- strsplit(x = images, split = '\\s{2,}')
    header <- gsub(pattern = ' ', replacement = '_', x = tolower(images[[1]]))
    images <- matrix(data = unlist(images[-1]), nrow = length(images) - 1,
                     ncol = length(header), byrow = TRUE)
    colnames(images) <- header
  }
  tibble::as_tibble(images)
}
