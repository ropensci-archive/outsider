# LIBS
library(outsider)
library(testthat)

# RUNNING
context('Testing \'container\'')
test_that('.container_init() works', {
  
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

# LIBS
library(outsider)
library(testthat)

# VARS
img_id <- 'test_img'
cntnr_id <- 'test_cntnr'
url <- paste0('https://raw.githubusercontent.com/DomBennett/',
              'om..hello.world/master/dockerfiles/latest')

# FUNCTIONS ----
cleanup <- function() {
  outsider:::docker_stop(cntnr_id = cntnr_id)
  outsider:::docker_img_rm(img_id = img_id)
}
build <- function() {
  expect_true(outsider:::docker_build(img_id = img_id, url = url))
}
build_and_start <- function() {
  build()
  expect_true(outsider:::docker_start(cntnr_id = cntnr_id, img_id = img_id))
}

# RUNNING
context('Testing \'modules\'')
test_that('docker_cmd() works', {
  expect_true(outsider:::docker_cmd(args = '--help'))
})
test_that('.docker_build() works', {
  expect_false(outsider:::docker_build(img_id = img_id, url = 'url'))
  expect_true(outsider:::docker_build(img_id = img_id, url = url))
  outsider:::docker_img_rm(img_id = img_id)
})
test_that('.docker_img_rm() works', {
  build()
  expect_true(outsider:::docker_img_rm(img_id = img_id))
})
test_that('.docker_start() works', {
  on.exit(cleanup())
  build()
  expect_false(outsider:::docker_start(cntnr_id = cntnr_id, img_id = 'notanimage'))
  expect_true(outsider:::docker_start(cntnr_id = cntnr_id, img_id = img_id))
  expect_true(outsider:::docker_stop(cntnr_id = cntnr_id))
})
test_that('.docker_stop() works', {
  on.exit(cleanup())
  build_and_start()
  expect_false(outsider:::docker_stop(cntnr_id = 'notacontainer'))
})
test_that('.docker_exec() works', {
  on.exit(cleanup())
  build_and_start()
  expect_true(outsider:::docker_exec(cntnr_id = cntnr_id, 'echo', 'Hello!'))
  expect_false(outsider:::docker_exec(cntnr_id = cntnr_id, 'notacommand'))
})
test_that('.docker_cp() works', {
  on.exit(cleanup())
  build_and_start()
  expect_true(outsider:::docker_cp(origin = paste0(cntnr_id, ':', 'hello.txt'),
                                   dest = 'hello.txt'))
  on.exit(file.remove('hello.txt'), add = TRUE)
  expect_true(file.exists('hello.txt'))
})
test_that('.docker_ps_count() works', {
  on.exit(cleanup())
  expect_true(outsider:::docker_ps_count() == 0)
  build_and_start()
  expect_true(outsider:::docker_ps_count() == 1)
})
