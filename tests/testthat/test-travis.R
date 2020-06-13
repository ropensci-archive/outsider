context('Testing \'travis\'')
test_that('travis_build_status() works', {
  skip_if_offline()
  skip_on_cran()
  res <- outsider:::travis_build_status(repo = 'dombennett/om..hello.world')
  expect_true(is.logical(res))
})