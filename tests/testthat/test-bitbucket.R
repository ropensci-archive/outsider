context('Testing \'bitbucket\'')
skip_if_offline()
skip_on_cran()
test_that('bitbucket_repo_search() works', {
  res <- bitbucket_repo_search(repo = 'dominicjbennett/om..hello.world')
  expect_true(inherits(res, 'data.frame'))
  expect_warning(bitbucket_repo_search(repo = 'dominicjbennett/notarepo'))
})
test_that('bitbucket_tags() works', {
  res <- bitbucket_tags(repos  = 'dominicjbennett/om..hello.world')
  expect_true(inherits(res, 'tbl_df'))
  expect_warning(bitbucket_tags(repos = 'dominicjbennett/notarepo'))
})
