context('Testing \'outsider\'')
test_that('verbosity_set() works', {
  expect_true(verbosity_set(show_program = FALSE))
  expect_false(outsider.base:::log_get(log = 'program_out'))
})
test_that('is_outsider_ready() works', {
  with_mock(
    `outsider:::is_docker_available` = function(...) TRUE,
    expect_true(is_outsider_ready())
  )
})
if(!requireNamespace("ssh", quietly = TRUE)) {
  skip("ssh package not available.")
}
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
