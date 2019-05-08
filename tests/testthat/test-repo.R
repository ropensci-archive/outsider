context('Testing \'repo\'')
test_that('address_unpack() works', {
  res <- outsider:::address_unpack(repo = 'dombennett/om..hello.world')
  expect_type(res, 'list')
  expect_error(outsider:::address_unpack(repo = 'om..hello.world'))
  expect_error(outsider:::address_unpack(repo = 'om..hello.world:master'))
  res <- outsider:::address_unpack(repo = 'service/username/repo:ref')
  expect_true(all(names(res) %in% unlist(res)))
})
test_that('pkgnm_guess() works', {
  with_mock(
    `outsider.base::modules_list` = function() 'm1',
    `outsider.base::meta_get` = function(...) list('url' = 'm1',
                                                   'package' = 'm1'),
    expect_equal(outsider:::pkgnm_guess(repo = 'm1', call_error = TRUE), 'm1'),
    expect_error(outsider:::pkgnm_guess(repo = 'm2', call_error = TRUE)),
    expect_null(outsider:::pkgnm_guess(repo = 'm2', call_error = FALSE))
  )
})
