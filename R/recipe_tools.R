download <- function(url, dr) {
  # download to temporary folder
  download.file(url = url, destfile = file.path(dr, 'download'))
}

bash <- function(scrpt_pth, variables) {
  script <- infuser::infuse(file_or_string = scrpt_pth, variables)
  write(x = script, file = file.path(variables[['tmpdr']], 'script.sh'))
  sys::exec_wait(cmd = 'bash', args = file.path(variables[['tmpdr']],
                                                'script.sh'))
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

ostype_get <- function() {
  sysinfo <- Sys.info()
  if (grepl(x = sysinfo[['sysname']], pattern = 'linux', ignore.case = TRUE)) {
    if (grepl(x = sysinfo[['machine']], pattern = '64')) {
      res <- 'linux64'
    } else {
      res <- 'linux32'
    }
  } else if (grepl(x = sysinfo[['sysname']], pattern = 'darwin',
                   ignore.case = TRUE)) {
    res <- 'osx'
  } else {
    stop('Unsupported OS.')
  }
  res
}

variables_get <- function(rcppth, lbpth) {
  tmpdr <- tempdir()
  if (!dir.exists(tmpdr)) dir.create(tmpdr)
  variables <- yaml::read_yaml(file = file.path(rcppth, 'variables.yml'))
  # check for OS type
  variables[['ostype']] <- variables[['ostype']][[ostype_get()]]
  variables <- c(variables, list('lbpth' = lbpth, 'tmpdr' = tmpdr))
  variables
}

meta_get <- function(rcppth, variables) {
  meta <- infuser::infuse(file_or_string = file.path(rcppth, 'meta.yml'),
                          variables)
  meta <- yaml::read_yaml(text = meta)
  meta
}
