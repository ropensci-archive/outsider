context('Testing \'install\'')
test_that('module_install() works', {
  with_mock(
    `outsider:::is_docker_available` = function(...) TRUE,
    `remotes::install_github` = function(...) TRUE,
    `remotes::install_url` = function(...) TRUE,
    `remotes::install_local` = function(...) TRUE,
    `outsider.base::image_install` = function(...) TRUE,
    expect_true(module_install(repo = repo, force = TRUE)),
    expect_true(module_install(url = '', force = TRUE)),
    expect_true(module_install(filepath = '', force = TRUE)),
    expect_error(module_install(filepath = '', url = '', force = TRUE))
  )
})
test_that('module_help() works', {
  expect_error(module_help(repo = 'githubuser/reponame'))
  with_mock(
    `outsider:::hlp_get` = function(...) TRUE,
    `outsider:::pkgnm_guess` = function(...) 'testthat',
    expect_true(module_help(repo = repo, fname = 'with_mock'))
  )
})
test_that('module_import() works', {
  expect_error(module_import(repo = 'githubuser/reponame', fname = 'foo'))
  with_mock(
    `outsider:::nmspc_get` = function(...) TRUE,
    `outsider:::pkgnm_guess` = function(...) 'testthat',
    expect_true(module_import(repo = repo, fname = 'with_mock'))
  )
})
test_that('is_module_installed() works', {
  with_mock(
    `outsider:::pkgnm_guess` = function(...) NULL,
    expect_false(is_module_installed(repo = repo))
  )
  with_mock(
    `outsider:::pkgnm_guess` = function(...) pkgnm,
    expect_true(is_module_installed(repo = repo))
  )
})
test_that('module_uninstall() works', {
  with_mock(
    `outsider:::pkgnm_guess` = function(...) pkgnm,
    `outsider.base:::uninstall` = function(...) TRUE,
    `outsider:::is_module_installed` = function(...) FALSE,
    expect_true(module_uninstall(repo = repo))
  )
})
test_that('module_installed() works', {
  fake_meta_get <- function(pkgnm) {
    switch(pkgnm,
           m1 = list('url' = 'https://cs.org/d1/m1', 'package' = 'm1',
                     'image' = 'd1/m1', 'program' = 'p1'),
           m2 = list('url' = 'https://cs.org/d2/m2', 'package' = 'm2',
                     'github' = 'd2', 'image' = 'd2/m2', 'program' = 'p2'),
           m3 = list('package' = 'm3', 'github' = 'd3', 'image' = 'd3/m3',
                     'program' = 'p3'))
  }
  avl_imgs <- data.frame(repository = c('d1/m1', 'd2/m2', 'ubuntu'),
                         tag = c('latest', '1.0', 'latest'),
                         image_id = as.character(1:3),
                         created = paste0('t', 1:3),
                         size = paste0(1:3, 'MB'), stringsAsFactors = FALSE)
  avl_imgs <- avl_imgs[sample(1:3), ]
  avl_imgs <- tibble::as_tibble(avl_imgs)
  res <- with_mock(
    `outsider.base::modules_list` = function() NULL,
    `outsider.base::docker_img_ls` = function() avl_imgs,
    `outsider.base::meta_get` = fake_meta_get,
    module_installed()
  )
  expect_true(nrow(res) == 0)
  res <- with_mock(
    `outsider.base::modules_list` = function() sample(paste0('m', 1:3)),
    `outsider.base::docker_img_ls` = function() avl_imgs,
    `outsider.base::meta_get` = fake_meta_get,
    module_installed()
  )
  expect_true(nrow(res) == 3)
  expect_true(sum(is.na(res[['tag']])) == 1)
  expect_true(sum(is.na(res[['image_created']])) == 1)
  expect_true(sum(is.na(res[['image_id']])) == 1)
  expect_true(res[res[['package']] == 'm1', 'tag'][[1]] == 'latest')
  expect_true(res[res[['package']] == 'm2', 'tag'][[1]] == '1.0')
})
