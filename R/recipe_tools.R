download <- function(url) {
  # download to temporary folder
}

setup <- function() {
  # extract
  # build
  # place in libs
}

args_extract <- function(cmd, help_arg = '-help') {
  help_output <- sys::exec_internal(cmd = cmd, args = help_arg, error = FALSE)
  if (help_output[['status']] != 0) {
    stop(paste0('`help_arg` or `cmd` is incorrect, see error output:\n\n',
                rawToChar(help_output[['stderr']])))
  }
  help_text <- rawToChar(help_output[['stdout']])
  help_lines <- strsplit(x = help_text, split = '\n')[[1]]
  args <- help_lines[grepl(pattern = '^\\s?-', x = help_lines)]
  args <- sub(pattern = '^\\s?-', replacement = '', x = args)
  sub(pattern = '\\s.*$', replacement = '', x = args)
}
