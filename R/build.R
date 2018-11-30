# skeleton

templates_get <- function() {
  fls <- list.files(path = system.file("extdata", package = "outsider"),
                    pattern = 'template_')
  templates <- vector(mode = 'list', length = length(fls))
  destpths <- sub(pattern = 'template_', replacement = '', x = fls)
  destpths <- gsub(pattern = '_', replacement = .Platform$file.sep,
                   x = destpths)
  for (i in seq_along(fls)) {
    flpth <- system.file("extdata", fls[[i]], package = "outsider")
    templates[[i]] <- stringr::str_c(readLines(con = flpth), collapse = '\n')
  }
  names(templates) <- destpths
  templates
}

strng_replace <- function(strng, skltn_vls) {
  for (i in seq_along(skltn_vls)) {
    pttrn <- skltn_vls[[i]][['pttrn']]
    rplcmnt <- skltn_vls[[i]][['val']]
    strng <- stringr::str_replace_all(string = strng, pattern = pttrn,
                                      replacement = rplcmnt)
  }
  strng
}

skltn_vls <- list(
  'Author name' = list('pttrn' = '%author_name%', 'val' = NA),
  'Author email' = list('pttrn' = '%author_email%', 'val' = NA),
  'Github username' = list('pttrn' = '%github_user%', 'val' = NA),
  'Docker username' = list('pttrn' = '%docker_user%', 'val' = NA),
  'R version' = list('pttrn' = '%r_version%', 'val' = NA),
  'Package name' = list('pttrn' = '%package_name%', 'val' = NA),
  'Program name' = list('pttrn' = '%program_name%', 'val' = NA),
  'Github repo' = list('pttrn' = '%repo%', 'val' = '')
)

file_create <- function(x, flpth) {
  basefl <- basename(path = flpth)
  dirpth <- sub(pattern = basefl, replacement = '', x = flpth)
  suppressWarnings(dir.create(path = dirpth, recursive = TRUE))
  write(x = x, file = flpth)
}

module_skeleton <- function() {
  skltn_vls[['R version']][['val']] <- paste0(version[['major']], '.',
                                                    version[['minor']])
  pkgnm <- readline(prompt = 'Package name: ')
  if (!grepl(pattern = '^om\\.\\.', x = pkgnm)) {
    stop('Invalid package name. Must begin ', char('om..'))
  }
  if (!dir.exists(pkgnm)) {
    dir.create(pkgnm)
  }
  skltn_vls[['Package name']][['val']] <- pkgnm
  for (i in seq_along(skltn_vls)) {
    if (is.na(skltn_vls[[i]][['val']])) {
      skltn_vls[[i]][['val']] <-
        readline(prompt = paste0(names(skltn_vls)[[i]], ': '))
    }
  }
  skltn_vls[['Github repo']][['val']] <-
    paste0(skltn_vls[['Github username']][['val']], '/',
           skltn_vls[['Package name']][['val']])
  templates <- templates_get()
  for (i in seq_along(templates)) {
    x <- strng_replace(strng = templates[[i]], skltn_vls = skltn_vls)
    file_create(x = x, flpth = file.path(pkgnm, names(templates)[[i]]))
  }
}

# build
# check
# test
# push

pkgnm_get <- function() {
  lines <- readLines(con = 'DESCRIPTION')
  pkgnm <- lines[grepl(pattern = '^Package:', x = lines)]
  pkgnm <- sub(pattern = '^Package:', replacement = '', x = pkgnm)
  pkgnm <- gsub(pattern = '\\s', replacement = '', x = pkgnm)
  pkgnm
}

# Public ----
module_build <- function(tag = 'latest') {
  cat_line(crayon::bold('Looking up package details ....'))
  pkgnm <- pkgnm_get()
  cat_line('... Package: ', char(pkgnm))
  repo <- pkgnm_to_repo(pkgnm = pkgnm)
  cat_line('... GitHub repo: ', char(repo))
  cat_line(crayon::bold('Building Docker image ....'))
  cat_line('... Tag: ', char(tag))
  flpth <- file.path(getwd(), 'dockerfiles', tag)
  img <- repo_to_img(repo)
  img_success <- docker_build(img = img, url_or_path = flpth, tag = tag)
  cat_line(crayon::bold('Building package ....'))
  pkg_success <- devtools::install(pkg = getwd())
  cat_line(crayon::bold('Pushing Docker image ....'))
  cat_line('... Docker repo: ', char(paste0(img, ':', tag)))
  push_success <- try(expr = docker_push(img = img, tag = tag), silent = TRUE)
  if (!push_success) {
    message('Failed to push. Do you have an account and are you logged in?')
  }
  invisible(img_success & pkg_success & push_success)
}

#' @name module_test
#' @title Test an outsider module
#' @description Ensure an outsider module builds, imports correctly and all
#' its functions successfully complete.
#' @details Success or fail, the module is uninstalled from the machine after
#' the test is run.
#' @param repo Module repo
#' @param verbose Print docker and program info to console
#' @return Logical
#' @export
#' @family user
module_test <- function(repo, verbose = FALSE) {
  res <- FALSE
  on.exit(expr = {
    if (res) {
      celebrate()
    } else {
      comfort()
    }})
  if (verbose) {
    temp_opts <- list(program_out = TRUE, program_err = TRUE,
                      docker_out = TRUE, docker_err = TRUE)
  } else {
    temp_opts <- list(program_out = FALSE, program_err = FALSE,
                      docker_out = FALSE, docker_err = FALSE)
  }
  res <- withr::with_options(new = temp_opts, code = .module_test(repo = repo))
  invisible(res)
}

# Private ----
.module_test <- function(repo) {
  on.exit(module_uninstall(repo = repo))
  tags <- module_tags(repos = repo)
  for (i in seq_len(nrow(tags))) {
    tag <- tags[i, 'name']
    tag <- paste0('Tag = ', char(vrsns[i, 'name']))
    res <- tryCatch(install_test(repo = repo, tag = tag),
                    error = function(e) {
                      message(paste0('Unable to install module! ', tag,
                                     ". See error below:\n\n"))
                      stop(e)
                    })
    res <- import_test(repo = repo)
    if (!res) {
      stop('Unable to import all module functions! ', tag, call. = FALSE)
    }
    res <- examples_test(repo = repo)
    if (!res) {
      stop('Unable to run all module examples! ', tag, call. = FALSE)
    }
  }
  invisible(res)
}
