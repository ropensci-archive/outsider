devtools::load_all('.')

# Github ----
# raw repo search
res <- github_repo_search(repo = 'dombennett/om..hello.world')
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                              'github_repo_search.RData'))
# raw all search
res <- github_search()
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                              'github_search.RData'))
# tags
res <- github_tags(repos = 'dombennett/om..hello.world')
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                       'github_tags.RData'))

# GitLab ----
# raw repo search
res <- gitlab_repo_search(repo = 'dombennett/om..hello.world')
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                       'gitlab_repo_search.RData'))
# raw all search
res <- gitlab_search()
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                       'gitlab_search.RData'))
# tags
res <- gitlab_tags(repo_ids  = '12231696')
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                       'gitlab_tags.RData'))

# BitBucket ----
# raw repo search
res <- bitbucket_repo_search(repo = 'dominicjbennett/om..hello.world')
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                       'bitbucket_repo_search.RData'))
# tags
res <- bitbucket_tags(repos = 'dominicjbennett/om..hello.world')
saveRDS(object = res, file = file.path('tests', 'testthat', 'data',
                                       'bitbucket_tags.RData'))
