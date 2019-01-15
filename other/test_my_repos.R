library(outsider)
my_repos <- c('dombennett/om..bamm',  'dombennett/om..hello.world',
              'dombennett/om..raxml', 'dombennett/om..mafft',
              'dombennett/om..blast', 'dombennett/om..pyrate')
for (repo in my_repos) {
  module_uninstall(repo)
  tryCatch(expr = .module_test(repo),
           error = function(e) {
             message(e)
           },
           warning = function(e) {
             message(e)
           })
}