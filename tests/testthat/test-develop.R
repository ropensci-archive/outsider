# LIBS
library(outsider)
library(testthat)

# VARS
repo <- 'dombennett/om..hello.world..1.0'
pkgnm <- .repo_to_pkgnm(repo = repo)

# RUNNING
context('Testing \'develop\'')
test_that('.run() works', {
  with_mock(
    `outsider:::.docker_cmd` = function(...) TRUE,
    expect_true(.run(pkgnm = pkgnm, files_to_send = NULL))
  )
})
test_that('.args_parse() works', {
  res <- .args_parse('a', 'b', 'c')
  expect_equal(res, c('a', 'b', 'c'))
})
test_that('.which_args_are_filepaths() works', {
  flnm <- 'testfile.txt'
  write('test', file = flnm)
  on.exit(file.remove(flnm))
  res <- .which_args_are_filepaths(c('notafile', flnm))
  expect_true(res == flnm)
  res <- .which_args_are_filepaths(c('notafile', flnm), wd = getwd())
  expect_true(file.path(getwd(), flnm) %in% res)
})
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
test_that('.travisyml_gen() works', {
  on.exit(file.remove('.travis.yml'))
  expect_true(.travisyml_gen(repo = repo))
})
test_that('.to_basename() works', {
  expctd <- list.files(getwd())[1]
  args <- c(file.path(getwd(), expctd), 'arg1', 'arg2')
  expect_true(.to_basename(args)[1] == expctd)
})
test_that('is_filepath() works', {
  files <- list.files(getwd())
  expect_true(all(outsider:::is_filepath(files)))
})
