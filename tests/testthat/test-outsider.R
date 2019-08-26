context('Testing \'outsider\'')
test_that('verbosity_set() works', {
  expect_true(verbosity_set(show_program = FALSE))
  expect_false(outsider.base:::log_get(log = 'program_out'))
})
test_that('ssh functions work', {
  with_mock(
    `outsider.base::server_connect` = function(session) TRUE,
    expect_true(ssh_setup(session = 'test'))
  )
  with_mock(
    `outsider.base::server_disconnect` = function() TRUE,
    expect_true(ssh_teardown())
  )
})
