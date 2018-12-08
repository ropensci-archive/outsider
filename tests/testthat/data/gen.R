devtools::load_all('.')

# raw repo search
repo <- outsider:::vars_get('repo')
search_args <- paste0('?q=', repo, '&', 'Type=Repositories')
github_res <- jsonlite::fromJSON(paste0(outsider:::gh_search_repo_url,
                                        search_args))
saveRDS(object = github_res, file = file.path('tests', 'testthat', 'data',
                                              'repo_search.RData'))
# raw all search
search_args <- paste0('?q=om..+in:name+outsider-module+in:description',
                      '&', 'Type=Repositories')
github_res <- jsonlite::fromJSON(paste0(gh_search_repo_url, search_args))
saveRDS(object = github_res, file = file.path('tests', 'testthat', 'data',
                                              'all_search.RData'))
