# Docker container class and functions

# Class ----
#' @name container-class
#' @aliases container-methods
#' @title Docker container class and methods
#' @description Return a list class that describes a Docker container.
#' The resulting class object comes with a series of convenience methods
#' for starting, stopping and interacting with a container.
#' @param pkgnm Package name
#' @param repo Repo
#' @param x container
#' @param ... Arguments
#' @return A list of class \code{container} with the following items:
#' \item{repo}{Repository of the outsider module}
#' \item{pkgnm}{Package name of the outsider module}
#' \item{prgrm}{Command to be called in the container}
#' \item{cntnr}{Unique Docker container name}
#' \item{img}{Image ID}
#' @family private-docker
container_init <- function(pkgnm = NULL, repo = NULL) {
  if (!is.null(pkgnm)) {
    ids <- ids_get(pkgnm = pkgnm)
  } else if (!is.null(repo)) {
    pkgnm <- repo_to_pkgnm(repo = repo)
    ids <- ids_get(pkgnm = pkgnm)
  } else {
    stop("No package or repo name provided.")
  }
  res <- list()
  res[['cntnr']] <- ids[['cntnr']]
  res[['img']] <- ids[['img']]
  if (length(ids[['tag']]) == 0) {
    stop('Missing docker image. Try reinstalling the module.', call. = FALSE)
  }
  res[['tag']] <- ids[['tag']]
  res[['repo']] <- pkgnm_to_repo(pkgnm = pkgnm)
  res[['prgrm']] <- pkgnm_to_prgm(pkgnm = pkgnm)
  res[['pkgnm']] <- pkgnm
  structure(res, class = 'container')
}

# Methods ----
start <- function(x, ...) {
  UseMethod('start', x)
}
halt <- function(x, ...) {
  UseMethod('halt', x)
}
exec <- function(x, ...) {
  UseMethod('exec', x)
}
status <- function(x, ...) {
  UseMethod('status', x)
}
copy <- function(x, ...) {
  UseMethod('copy', x)
}
run <- function(x, ...) {
  UseMethod('run', x)
}

# Functions ----
#' @rdname container-class
start.container <- function(x) {
  args <- c('run', '-t', '-d', '--name', x[['cntnr']], x[['img']])
  docker_cmd(args = args, std_out = log_get('docker_out'),
             std_err = log_get('docker_err'))
}

#' @rdname container-class
halt.container <- function(x) {
  cntnr <- x[['cntnr']]
  args1 <- c('stop', cntnr)
  res1 <- docker_cmd(args = args1, std_out = log_get('docker_out'),
                      std_err = log_get('docker_err'))
  args2 <- c('rm', cntnr)
  res2 <- docker_cmd(args = args2, std_out = log_get('docker_out'),
                      std_err = log_get('docker_err'))
  res1 & res2
}

#' @rdname container-class
exec.container <- function(x, ...) {
  args <- c('exec', x[['cntnr']], ...)
  docker_cmd(args, std_out = log_get('program_out'),
             std_err = log_get('program_err'))
}

#' @rdname container-class
status.container <- function(x) {
  check <- function(argmnts) {
    res <- sys::exec_internal(cmd = 'docker', args = argmnts)
    res[['status']] == 0 && grepl(paste0('\\s+', cntnr, '\n'),
                                  rawToChar(res[['stdout']]))
  }
  cntnr <- x[['cntnr']]
  name_arg <- paste0('name=', cntnr)
  # running
  res <- check(argmnts = c('ps', '-f', name_arg))
  if (res) {
    return('Running')
  }
  res <- check(argmnts = c('ps', '-a', '-f', name_arg))
  if (res) {
    return('Stopped')
  }
  'Not running'
}

#' @rdname container-class
#' @details All outsider modules have a \code{working_dir/} in which generated
#' files are created and initiation files must be for the program to use.
#' Files must be sent to this working directory and then returned before and
#' after the program has run.
#' 
#' If no \code{send} or \code{rtrn} specified, returns TRUE.
#' @param send Filepaths to send from host computer to container.
#' @param rtrn Directory on host computer where returning files should be sent.
copy.container <- function(x, send = NULL, rtrn = NULL) {
  cntnr <- x[['cntnr']]
  if (!is.null(send)) {
    res <- TRUE
    for (host_flpth in send) {
      res <- res & docker_cp(origin = host_flpth,
                             dest = paste0(cntnr, ':', '/working_dir/'))
    }
    return(invisible(res))
  }
  if (!is.null(rtrn)) {
    res <- docker_cp(origin = paste0(cntnr, ':', '/working_dir/.'),
                     dest = rtrn)
    return(invisible(res))
  }
  invisible(TRUE)
}

#' @rdname container-class
#' @param cmd Command name, character
#' @param args List or vector of arguments, character
run.container <- function(x, cmd, args) {
  success <- tryCatch(expr = {
    exec(x = x, cmd, args)},
    error = function(e) {
      message('Unexpected error has occurred. Safely exiting...')
      e
    },
    interrupt = function(e) {
      message('User halted. Safely exiting...')
      FALSE
    })
  success
}

#' @export
print.container <- function(x, ...) {
  cat_line(cli::rule())
  cat_line(crayon::bold('Docker container details:'))
  cat_line('Image ', char(x[['img']]))
  cat_line('Container ', char(x[['cntnr']]))
  cat_line('Tag ', char(x[['tag']]))
  cat_line('Status ', char(status.container(x)))
  cat_line(cli::rule())
  cat_line(crayon::bold('Outsider module details:'))
  cat_line('Repo ', char(x[['repo']]))
  cat_line('R package ', char(x[['pkgnm']]))
  cat_line('Program ', char(x[['prgrm']]))
  cat_line(cli::rule())
}
