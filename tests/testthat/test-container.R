# LIBS
library(outsider)
library(testthat)

# Vars ----
repo <- outsider:::vars_get('repo')
pkgnm <- outsider:::vars_get('pkgnm')
img <- outsider:::vars_get('img')
cntnr <- outsider:::vars_get('cntnr')
tag <- 'latest'

# RUNNING ----
context('Testing \'container\'')
test_that('container_init() works', {
  with_mock(
    `outsider:::ids_get` = function(...) c('img' = img, 'cntnr' = cntnr,
                                           'tag' = tag),
    expect_true(inherits(outsider:::container_init(pkgnm = pkgnm),
                         'container'))
  )
  with_mock(
    `outsider:::ids_get` = function(...) c('img' = img, 'cntnr' = cntnr,
                                           'tag' = tag),
    expect_true(inherits(outsider:::container_init(repo = repo),
                         'container'))
  )
  expect_error(outsider:::container_init())
})
test_that('run.container() works', {
  container <- structure(list(), class = 'container')
  with_mock(
    `outsider:::exec.container` = function(x, ...) TRUE,
    expect_true(outsider:::run.container(x = container, cmd = '', args = ''))
  )
  res <- with_mock(
    `outsider:::exec.container` = function(x, ...) stop(),
    outsider:::run.container(x = container, cmd = '', args = '')
  )
  expect_true(inherits(res, 'simpleError'))
})
test_that('print.container() works', {
   with_mock(
    `outsider:::ids_get` = function(...) c('img' = img, 'cntnr' = cntnr,
                                           'tag' = tag),
    `outsider:::status.container` = function(x, ...) 'This is a mock',
    container <- outsider:::container_init(pkgnm = pkgnm),
    print(container)
  )
})
test_that('container methods work', {
  # set-up
  outsider:::docker_pull(img = img)
  container <- with_mock(
    `outsider:::ids_get` = function(...) c('img' = img, 'cntnr' = cntnr,
                                           'tag' = tag),
    outsider:::container_init(pkgnm = pkgnm)
  )
  # pull down
  on.exit(outsider:::docker_img_rm(img = img))
  # tests
  expect_true(outsider:::status.container(container) == 'Not running')
  expect_true(outsider:::start.container(container))
  expect_true(outsider:::exec.container(container, 'touch', 'file_to_return'))
  expect_true(outsider:::copy.container(container, rtrn = getwd()))
  expect_true(file.exists('file_to_return'))
  expect_true(file.remove('file_to_return'))
  expect_true(file.create('file_to_send'))
  expect_true(outsider:::copy.container(container, send = 'file_to_send'))
  expect_true(file.remove('file_to_send'))
  #expect_true(outsider:::exec(container, 'ls'))
  expect_true(outsider:::status.container(container) == 'Running')
  expect_true(outsider:::halt.container(container))
})
