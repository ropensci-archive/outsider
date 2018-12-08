test_that('.copy_to_docker() works', {
  with_mock(
    `outsider:::.docker_cmd` = function(...) TRUE,
    expect_true(.copy_to_docker(cntnr_id = '', host_flpths = rep('file', 10)))
  )
})
test_that('.copy_from_docker() works', {
  with_mock(
    `outsider:::.docker_cmd` = function(...) TRUE,
    expect_true(.copy_from_docker(cntnr_id = ''))
  )
})
