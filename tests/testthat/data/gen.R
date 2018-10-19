devtools::load_all('.')
# search results
srch <- om_search()
saveRDS(object = srch, file = file.path('tests', 'testthat', 'data',
                                        'om_search.RData'))
# yaml results
info <- om_yaml(repos = srch[['full_name']])
saveRDS(object = info, file = file.path('tests', 'testthat', 'data',
                                        'om_yaml.RData'))
