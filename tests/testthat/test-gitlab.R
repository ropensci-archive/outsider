context('Testing \'gitlab\'')
skip_if_offline()
skip_on_cran()
# if no gitlab token, skip
skip_if(is.null(outsider:::authtoken_get(service = 'gitlab')))
test_that('gitlab_repo_search() works', {
  res <- gitlab_repo_search(repo = 'DomBennett/om..hello.world')
  expect_true(inherits(res, 'data.frame'))
  expect_warning(gitlab_repo_search(repo = 'DomBennett/notarepo'))
})
test_that('gitlab_search() works', {
  res <- gitlab_search()
  expect_true(inherits(res, 'data.frame'))
})
test_that('gitlab_tags() works', {
  res <- gitlab_tags(repo_ids  = '12231696')
  expect_true(inherits(res, 'tbl_df'))
  expect_warning(gitlab_tags(repo_ids = 'notarepoid'))
})
