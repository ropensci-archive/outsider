# TODO: add more mock data to reduce dependance on internet
context('Testing \'github\'')
test_that('authtoken_get() works', {
  expect_true(is.character(outsider:::authtoken_get()) |
                is.null(outsider:::authtoken_get()))
})
test_that('github_repo_search() works', {
  with_mock(
    `jsonlite::fromJSON` = mock_repo_search_0,
    expect_true(inherits(outsider:::github_repo_search(repo = repo),
                         'data.frame'))
  )
  with_mock(
    `jsonlite::fromJSON` = mock_repo_search_1,
    expect_warning(outsider:::github_repo_search(repo = repo))
  )
  with_mock(
    `jsonlite::fromJSON` = mock_repo_search_2,
    expect_warning(outsider:::github_repo_search(repo = repo))
  )
})
test_that('github_search() works', {
  with_mock(
    `jsonlite::fromJSON` = mock_all_search_bad,
    expect_warning(expect_true(inherits(outsider:::github_search(),
                                        'data.frame')))
  )
})
test_that('github_yaml() works', {
  # TODO: with mock?
  skip_if_offline()
  res <- outsider:::github_yaml(repos = repo)
  expect_true(inherits(res, 'tbl_df'))
})
test_that('github_tags() works', {
  # TODO: with mock?
  skip_if_offline()
  res <- outsider:::github_tags(repos = repo)
  expect_true(inherits(res, 'tbl_df'))
})
