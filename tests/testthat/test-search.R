# TODO: add more mock data to reduce dependance on internet
#        record the code to gen the mock data. 
context('Testing \'search\'')
test_that('authtoken_get() works', {
  expect_true(is.character(outsider:::authtoken_get()) |
                is.null(outsider:::authtoken_get()))
})
test_that('yaml_fetch() works', {
  res <- outsider:::yaml_fetch(url = file.path(datadir, 'om.yml'))
  expect_true(inherits(res, 'list'))
  expect_equal(res[['program']], 'hello world')
})
test_that('yaml_read() works', {
  skip_if_offline()
  res <- outsider:::yaml_read(repos = 'dombennett/om..hello.world',
                              service = 'github')
  expect_true(inherits(res, 'tbl_df'))
  res <- outsider:::yaml_read(repos = 'dombennett/om..hello.world',
                              service = 'gitlab')
  expect_true(inherits(res, 'tbl_df'))
  res <- outsider:::yaml_read(repos = 'dominicjbennett/om..hello.world',
                              service = 'bitbucket')
  expect_true(inherits(res, 'tbl_df'))
})
test_that('module_search() works', {
  res <- with_mock(
    `outsider:::github_search` = mock_github_search,
    module_search(service = 'github')
  )
  expect_true(inherits(res, 'character'))
  res <- with_mock(
    `outsider:::gitlab_search` = mock_gitlab_search,
    module_search(service = 'gitlab')
  )
  expect_true(inherits(res, 'character'))
})
test_that('module_details() works', {
  # github
  with_mock(
    `outsider:::github_search` = mock_github_search,
    `outsider:::github_repo_search` = mock_github_repo_search,
    `outsider:::github_tags` = mock_github_tags,
    `outsider:::yaml_fetch` = mock_yaml_fetch,
    res <- module_details(repo = c('dombennett/om..hello.world',
                                   'dombennett/om..mafft'),
                          service = 'github'),
    expect_true(inherits(res, 'tbl_df')),
    res <- module_details(service = 'github'),
    expect_true(inherits(res, 'tbl_df'))
  )
  # gitlab
  with_mock(
    `outsider:::gitlab_search` = mock_gitlab_search,
    `outsider:::gitlab_repo_search` = mock_gitlab_repo_search,
    `outsider:::gitlab_tags` = mock_gitlab_tags,
    `outsider:::yaml_fetch` = mock_yaml_fetch,
    res <- module_details(repo = 'dombennett/om..hello.world',
                          service = 'gitlab'),
    expect_true(inherits(res, 'tbl_df')),
    res <- module_details(service = 'gitlab'),
    expect_true(inherits(res, 'tbl_df'))
  )
  # bb
  with_mock(
    `outsider:::bitbucket_repo_search` = mock_bitbucket_repo_search,
    `outsider:::bitbucket_tags` = mock_bitbucket_tags,
    `outsider:::yaml_fetch` = mock_yaml_fetch,
    res <- module_details(repo = 'dominicjbennett/om..hello.world',
                          service = 'bitbucket'),
    expect_true(inherits(res, 'tbl_df')),
    expect_error(module_details(service = 'bitbucket'))
  )
})
