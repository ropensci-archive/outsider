context('Testing \'download\'')
test_that('download_and_install() works', {
  with_mock(
    `outsider:::download_file` = function(destfile, ...) {
      write(x = '', file = destfile)
    },
    `outsider:::untar2` = function(exdir, ...) {
      write(x = '', file = file.path(exdir, 'test'))
    },
    `outsider.base::install` = function(...) TRUE,
    expect_true(download_and_install(url = ''))
  )
  with_mock(
    `outsider:::download_file` = function(...) NULL,
    `outsider:::untar2` = function(...) NULL,
    `outsider.base::install` = function(...) TRUE,
    expect_error(download_and_install(url = ''))
  )
})
test_that('url_make() works', {
  skip_if_offline()
  # github
  url <- outsider:::url_make(username = 'torvalds', repo = 'linux')
  expect_type(url, 'character')
  # bitbucket
  url <- outsider:::url_make(username = 'dominicjbennett',
                             repo = 'om..hello.world', service = 'bitbucket')
  expect_type(url, 'character')
  # gitlab
  url <- outsider:::url_make(username = 'dombennett',
                             repo = 'om..hello.world', service = 'gitlab')
  expect_type(url, 'character')
  # expect error
  expect_error(outsider:::url_make(username = 'dombennett',
                                   repo = 'unlikelyreponame',
                                   service = 'github'))
})
