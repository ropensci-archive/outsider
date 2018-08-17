cmdr <- function(cmd, args) {
  # ensure cmd is available
  # ensure args are valid
  output <- sys::exec_internal(cmd = cmd, args = args, error = FALSE)
  if (output[['status']] == 0) {
    res <- rawToChar(output[['stdout']])
  } else {
    res <- rawToChar(output[['stderr']])
  }
  res
}

cmds_get <- function() {
  list.files(path = lbpth)
}

args_get <- function(cmd) {
  readRDS(file = file.path(argpth, cmd))
}

path_get <- function(cmd) {
  res <- ''
  if (cmd_available) {
    res <- file.path(lbpth, cmd)
  }
  res
}

cmd_available <- function(cmd) {
  cmd %in% cmds_get()
}
