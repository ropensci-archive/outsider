library(outsider)
# NOT RUN (too slow for automated testing)
\dontrun{
  if (is_outsider_ready()) {
    # simplest repo
    repo <- 'dombennett/om..hello.world'
    # install
    module_install(repo = repo, force = TRUE, update = 'never')
    # is module_installed?
    (is_module_installed(repo = repo))
    # uninstall
    module_uninstall(repo)
  }
}
