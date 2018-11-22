

container_class <- function(pkgnm = NULL, repo = NULL) {
  if (!is.null(pkgnm)) {
    res <- .ids_get(pkgnm = pkgnm)
  } else if (!is.null(repo)) {
    pkgnm <- .repo_to_pkgnm(repo = repo)
    res <- .ids_get(pkgnm = pkgnm)
  } else {
    stop("No package or repo name provided.")
  }
  res <- as.list(res)
  res[['repo']] <- .pkgnm_to_repo(pkgnm = pkgnm)
  res[['prgrm']] <- .pkgnm_to_prgm(pkgnm = pkgnm)
  res[['pkgnm']] <- pkgnm
  structure(res, class = 'container')
}

start <- function(x, ...) {
  UseMethod('start', x)
}
start.container <- function(x) {
  args <- c('run', '-t', '-d', '--name', x[['cntnr_id']], x[['img_id']])
  .docker_cmd(args = args, std_out = log_get('docker_out'),
              std_err = log_get('docker_err'))
}

halt <- function(x, ...) {
  UseMethod('halt', x)
}
halt.container <- function(x) {
  cntnr_id <- x[['cntnr_id']]
  args1 <- c('stop', cntnr_id)
  res1 <- .docker_cmd(args = args1, std_out = log_get('docker_out'),
                      std_err = log_get('docker_err'))
  args2 <- c('rm', cntnr_id)
  res2 <- .docker_cmd(args = args2, std_out = log_get('docker_out'),
                      std_err = log_get('docker_err'))
  res1 & res2
}

exec <- function(x, ...) {
  UseMethod('exec', x)
}
exec.container <- function(x, ...) {
  args <- c('exec', x[['cntnr_id']], ...)
  .docker_cmd(args, std_out = log_get('program_out'),
              std_err = log_get('program_err'))
}

status <- function(x, ...) {
  UseMethod('status', x)
}
status.container <- function(x) {
  check <- function(argmnts) {
    res <- sys::exec_internal(cmd = 'docker', args = argmnts)
    res[['status']] == 0 && grepl(paste0('\\s+', cntnr_id, '\n'),
                                  rawToChar(res[['stdout']]))
  }
  cntnr_id <- x[['cntnr_id']]
  name_arg <- paste0('name=', cntnr_id)
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

print.container <- function(x) {
  cat_line(cli::rule())
  cat_line(crayon::bold('Docker container details:'))
  cat_line('Image ', char(x[['img_id']]))
  cat_line('Container ', char(x[['cntnr_id']]))
  cat_line('Status ', char(status.container(x)))
  cat_line(cli::rule())
  cat_line(crayon::bold('Outsider module details:'))
  cat_line('Repo ', char(x[['repo']]))
  cat_line('R package ', char(x[['pkgnm']]))
  cat_line('Program ', char(x[['prgrm']]))
  cat_line(cli::rule())
}
