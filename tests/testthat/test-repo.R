context('Testing \'repo\'')
test_that('pkgnm_guess() works', {
  fake_meta_get <- function(pkgnm) {
    switch(pkgnm, m1 = list('url' = 'https://cs.org/d1/m1',
                            'package' = 'm1'),
           m2 = list('url' = 'https://cs.org/d2/m2', 'package' = 'm2',
                     'github' = 'd2'),
           m3 = list('package' = 'm3',
                     'github' = 'd3'))
  }
  with_mock(
    `outsider.base::modules_list` = function() paste0('m', 1:3),
    `outsider.base::meta_get` = fake_meta_get,
    expect_equal(outsider:::pkgnm_guess(repo = 'm1', call_error = TRUE), 'm1'),
    expect_equal(outsider:::pkgnm_guess(repo = 'd2/m2', call_error = TRUE),
                 'm2'),
    expect_equal(outsider:::pkgnm_guess(repo = 'd3/m3', call_error = TRUE),
                 'm3'),
    expect_error(outsider:::pkgnm_guess(repo = 'm4', call_error = TRUE)),
    expect_null(outsider:::pkgnm_guess(repo = 'm4', call_error = FALSE))
  )
})
