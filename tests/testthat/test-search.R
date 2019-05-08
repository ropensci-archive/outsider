# TODO: add more mock data to reduce dependance on internet
#        record the code to gen the mock data. 
context('Testing \'search\'')
test_that('yaml_read() works', {
  res <- outsider:::yaml_read(url = file.path(datadir, 'om.yml'))
  expect_true(inherits(res, 'list'))
  expect_equal(res[['program']], 'hello world')
})
test_that('module_search() works', {
  res <- with_mock(
    `jsonlite::fromJSON` = mock_all_search,
    module_search()
  )
  expect_true(inherits(res, 'character'))
})
test_that('module_details() works', {
  skip_if_offline()
  # TODO: with mock?
  res <- module_details(repo = c(repo, 'dombennett/om..mafft'),
                        service = 'github')
  expect_true(inherits(res, 'tbl_df'))
})
# test_that('module_exists() works', {
#   with_mock(
#     `outsider:::build_status` = function(...) TRUE,
#     expect_true(all(module_exists(repo = c(repo, repo))))
#   )
# })
