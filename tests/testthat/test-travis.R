context('Testing \'travis\'')
test_that('travis_build_status() works', {
  with_mock(
    `outsider:::github_repo_search` = function(repo) list(),
    `jsonlite::fromJSON` = function(...) stop(),
    expect_false(outsider:::travis_build_status(repo = repo,
                                                service = 'github'))
  )
  with_mock(
    `outsider:::github_repo_search` = function(repo) list(),
    `jsonlite::fromJSON` = function(...) list('last_build_status' = 0),
    expect_true(outsider:::travis_build_status(repo = repo, service = 'github'))
  )
})