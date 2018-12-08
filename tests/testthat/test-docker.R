# LIBS
library(outsider)
library(testthat)

# VARS
img <- 'test_img'
cntnr <- 'test_cntnr'
url <- paste0('https://raw.githubusercontent.com/DomBennett/',
              'om..hello.world/master/dockerfiles/latest/Dockerfile')
expctd_1 <- "REPOSITORY   TAG   IMAGE ID   CREATED   SIZE
dombennett/om_hello.world   latest   c0cb087733b9   1 day ago   100MB"
expctd_2 <- "REPOSITORY   TAG   IMAGE ID   CREATED   SIZE"

# RUNNING
context('Testing \'docker\'')
test_that('is_docker_available() works', {
  with_mock(
    `outsider:::is_docker_installed` = function(...) FALSE,
    `outsider:::is_docker_running` = function(...) FALSE,
    expect_error(outsider:::is_docker_available())
  )
  with_mock(
    `outsider:::is_docker_installed` = function(...) TRUE,
    `outsider:::is_docker_running` = function(...) FALSE,
    expect_error(outsider:::is_docker_available())
  )
  with_mock(
    `outsider:::is_docker_installed` = function(...) TRUE,
    `outsider:::is_docker_running` = function(...) TRUE,
    expect_null(outsider:::is_docker_available())
  )
})
test_that('is_docker_installed() works', {
  with_mock(
    `sys::exec_internal` = function(...) list('status' = 1),
    expect_false(outsider:::is_docker_installed())
  )
  expect_true(outsider:::is_docker_installed())
})
test_that('is_docker_running() works', {
  with_mock(
    `sys::exec_internal` = function(...) list('status' = 1),
    expect_false(outsider:::is_docker_running())
  )
  expect_true(outsider:::is_docker_running())
})
test_that('docker_cmd() works', {
  expect_true(outsider:::docker_cmd(args = '--help'))
})
test_that('docker_pull() works', {
  expect_true(outsider:::docker_pull(img = outsider:::vars_get('img')))
})
test_that('docker_build() and docker_img_rm() works', {
  expect_false(outsider:::docker_build(img = img, url_or_path = 'url'))
  expect_true(outsider:::docker_build(img = img, url_or_path = url))
  expect_true(outsider:::docker_img_rm(img = img))
})
test_that('docker_cp() works', {
  with_mock(
    `outsider:::docker_cmd` = function(...) TRUE,
    expect_true(outsider:::docker_cp(origin = '.', dest = '.'))
  )
})
test_that('docker_ps_count() works', {
  expect_true(outsider:::docker_ps_count() == 0)
})
test_that('docker_img_ls() works', {
  res <- with_mock(
    `sys::exec_internal` = function(...) list('status' = 0,
                                              'stdout' = charToRaw(expctd_1)),
    outsider:::docker_img_ls()
  )
  expect_true(nrow(res) == 1)
  res <- with_mock(
    `sys::exec_internal` = function(...) list('status' = 1,
                                              'stdout' = charToRaw(expctd_1)),
    outsider:::docker_img_ls()
  )
  expect_true(nrow(res) == 0)
  res <- with_mock(
    `sys::exec_internal` = function(...) list('status' = 0,
                                              'stdout' = charToRaw(expctd_2)),
    outsider:::docker_img_ls()
  )
  expect_true(nrow(res) == 0)
})
