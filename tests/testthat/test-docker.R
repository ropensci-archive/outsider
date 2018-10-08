# LIBS
library(outsider)
library(testthat)

# VARS
img_id <- 'test_img'
cntnr_id <- 'test_cntnr'
url <- paste0('https://raw.githubusercontent.com/DomBennett/',
              'om..hello.world..1.0/master/Dockerfile')

# FUNCTIONS ----
cleanup <- function() {
  .docker_stop(cntnr_id = cntnr_id)
  .docker_img_rm(img_id = img_id)
}
build <- function() {
  expect_true(.docker_build(img_id = img_id, url = url))
}
build_and_start <- function() {
  build()
  expect_true(.docker_start(cntnr_id = cntnr_id, img_id = img_id))
}

# RUNNING
context('Testing \'modules\'')
test_that('.docker_cmd() works', {
  expect_true(.docker_cmd(args = '--help'))
})
test_that('.docker_build() works', {
  expect_false(.docker_build(img_id = img_id, url = 'url'))
  expect_true(.docker_build(img_id = img_id, url = url))
  .docker_img_rm(img_id = img_id)
})
test_that('.docker_img_rm() works', {
  build()
  expect_true(.docker_img_rm(img_id = img_id))
})
test_that('.docker_start() works', {
  on.exit(cleanup())
  build()
  expect_false(.docker_start(cntnr_id = cntnr_id, img_id = 'notanimage'))
  expect_true(.docker_start(cntnr_id = cntnr_id, img_id = img_id))
  expect_true(.docker_stop(cntnr_id = cntnr_id))
})
test_that('.docker_stop() works', {
  on.exit(cleanup())
  build_and_start()
  expect_false(.docker_stop(cntnr_id = 'notacontainer'))
})
test_that('.docker_exec() works', {
  on.exit(cleanup())
  build_and_start()
  expect_true(.docker_exec(cntnr_id = cntnr_id, 'echo', 'Hello!'))
  expect_false(.docker_exec(cntnr_id = cntnr_id, 'notacommand'))
})
test_that('.docker_cp() works', {
  on.exit(cleanup())
  build_and_start()
  expect_true(.docker_cp(origin = paste0(cntnr_id, ':', 'hello.txt'),
                         dest = 'hello.txt'))
  on.exit(file.remove('hello.txt'), add = TRUE)
  expect_true(file.exists('hello.txt'))
})
test_that('.docker_ps_count() works', {
  on.exit(cleanup())
  expect_true(.docker_ps_count() == 0)
  build_and_start()
  expect_true(.docker_ps_count() == 1)
})
