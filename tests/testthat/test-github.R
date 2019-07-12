context('Testing \'github\'')
test_that('github_repo_search() works', {
  skip_if_offline()
  res <- github_repo_search(repo = 'dombennett/om..hello.world')
  expect_true(inherits(res, 'data.frame'))
})
test_that('github_search() works', {
  skip_if_offline()
  res <- github_search()
  expect_true(inherits(res, 'data.frame'))
})
test_that('github_tags() works', {
  skip_if_offline()
  res <- github_tags(repos  = 'dombennett/om..hello.world')
  expect_true(inherits(res, 'tbl_df'))
})
