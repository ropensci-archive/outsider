context('Testing \'outsider\'')
test_that('verbosity_set() works', {
  expect_true(verbosity_set(show_program = FALSE))
  expect_false(outsider.base:::log_get(log = 'program_out'))
})