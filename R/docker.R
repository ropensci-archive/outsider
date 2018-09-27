docker_cmd <- function(args) {
  res <- sys::exec_wait(cmd = 'docker', args = args)
  res == 0
}

docker_build <- function(img_id, url) {
  args <- c('build', '-t', img_id, url)
  docker_cmd(args = args)
}

docker_start <- function(cntnr_id, img_id) {
  args <- c('run', '-t', '-d', '--name', cntnr_id, img_id)
  docker_cmd(args = args)
}

docker_stop <- function(cntnr_id) {
  args1 <- c('stop', cntnr_id)
  res1 <- docker_cmd(args = args1)
  args2 <- c('rm', cntnr_id)
  res2 <- docker_cmd(args = args2)
  res1 & res2
}

docker_exec <- function(cntnr_id, ...) {
  args <- c('exec', cntnr_id, ...)
  docker_cmd(args)
}

docker_ps_count <- function() {
  res <- sys::exec_internal(cmd = 'docker', args = 'ps')
  if (res[['status']] == 0) {
    ps <- strsplit(x = rawToChar(res[['stdout']]), split = '\n')[[1]][-1]
    return(length(ps))
  }
  0
}
