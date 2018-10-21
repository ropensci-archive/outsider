devtools::load_all('.')

repo <- 'dombennett/om..revbayes'
repo <- 'dombennett/om..hello.world..1.0'
repo <- 'dombennett/om..mafft..7.407.wextensions'
repo <- 'dombennett/om..raxml..8.2.12.sse3.pthreads'
repo <- 'dombennett/om..pyrate..2.0'


library(outsider)
repo <- 'dombennett/om..pyrate..2.0'
module_install(repo = repo)
module_help(repo = repo)
module_help(repo = repo, fname = 'PyRate')
pyrate <- module_import(fname = 'PyRate', repo = repo)
pyrate('-h')
pyrate('Rhinocerotidae_PyRate.py', '-wd',
       '/Users/djb208/Coding/PyRate/example_files/')


om..pyrate..2.0..dombennett:::base_function

args <- c('Rhinocerotidae_PyRate.py', '-wd',
         '/Users/djb208/Coding/PyRate/example_files/')
if ('-wd' %in% args) {
  wd_i <- which(args == '-wd')
  wd <- args[wd_i + 1]
  # if wd is specified, then drop from args
  args <- args[-1 * c(wd_i, wd_i + 1)]
} else {
  pattern <- paste0(.Platform$file.sep, basename(args[1]))
  wd <- sub(pattern = pattern, replacement = '', x = args[1])
}
files_to_send <- outsider::.which_args_are_filepaths(args, wd)
outsider::.run(pkgnm = pkgnm, files_to_send = files_to_send, dest = wd,
               'python2.7', paste0('/PyRate/', cmd),
               outsider::.to_basename(args))

pattern <- paste0(.Platform$file.sep, basename(args[1]))
wd <- sub(pattern = pattern, replacement = '', x = args[1])

pattern <- paste0(.Platform$file.sep, basename(args[1]))
wd <- sub(pattern = pattern, replacement = "", x = args[1])
files_to_send <- outsider::.which_args_are_filepaths(args)

cmd <- "PyRate.py"
pkgnm <- .repo_to_pkgnm(repo)
outsider::.run(pkgnm = pkgnm, files_to_send = files_to_send, 
               dest = wd, "python2.7", paste0("/PyRate/", cmd),
               .drop_filepaths(args))

.drop_filepaths <- function(args) {
  files_and_folders <- vapply(X = args, FUN = function(x) file.exists(x) ||
                                dir.exists(x), FUN.VALUE = logical(1))
  args[files_and_folders] <- basename(args[files_and_folders])
  args
}

pyrate(help = TRUE)
module_uninstall(repo = repo)

repo <- 'dombennett/om..hello.world..1.0'
library(outsider)
module_test(repo)

repo <- 'dombennett/om..mafft..7.407'
library(outsider)
module_test(repo)

repo <- 'DomBennett/om..raxml..8.2.12.pthreads.sse3'
library(outsider)
module_test(repo)

repo <- 'dombennett/om..pyrate..2.0'
library(outsider)
module_test(repo)





library(outsider)
repo <- 'dombennett/om..hello.world..1.0'
module_install(repo = repo)
module_help(repo = repo)
module_help(repo = repo, fname = 'hello_world')
hello_world <- module_import(fname = 'hello_world', repo = repo)
hello_world()
module_uninstall(repo = repo)














