library(outsider)
if (is_outsider_ready()) {
  # simplest repo
  repo <- 'dombennett/om..hello.world'

  # is module_installed?
  if (is_module_installed(repo = repo)) {

    # get help for package
    module_help(repo = repo)
    
    # list functions available
    module_functions(repo = repo)
    
    # import
    hello_world <- module_import(fname = 'hello_world', repo = repo)
    
    # get help for function
    module_help(repo = repo, fname = 'hello_world')
    # also works
    ?hello_world

    # run function
    hello_world()
    
    # change verbosity settings
    
    # print nothing to console
    verbosity_set(show_program = FALSE, show_docker = FALSE)
    hello_world()
    
    # print everything to console
    verbosity_set(show_program = TRUE, show_docker = TRUE)
    hello_world()
    
    # write program output to a file
    log_file <- tempfile()
    verbosity_set(show_program = log_file, show_docker = FALSE)
    
    hello_world()
    
    (readLines(con = log_file))
    
    # Clean up
    file.remove(log_file)
  }
}
