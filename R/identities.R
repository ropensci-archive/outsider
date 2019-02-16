# Identity functions
#     Once a module is installed, all identities (img, Docker username etc.) can
#     be determined from the GitHub repo.

# Get ----
#' @name ids_get
#' @title Get docker names for a module
#' @description From a pkgnm, return the image and container names.
#' @param pkgnm Package name of module
#' @return Logical
#' @family private-ids
ids_get <- function(pkgnm) {
  repo <- pkgnm_to_repo(pkgnm)
  img <- repo_to_img(repo)
  prgrm <- pkgnm_to_prgm(pkgnm)
  nps <- docker_ps_count()
  imgs <- docker_img_ls()
  #print(imgs)
  if ('tag' %in% colnames(imgs)) {
    pull <- imgs[['repository']] == img
    if (any(pull)) {
      tag <- imgs[pull, 'tag'][[1]]
      tag <- tag[[1]]
    } else {
      stop(char(repo), ' is missing its Docker image, try reinstalling.')
    }
  } else {
    # Sometimes there is no tag column (?)
    tag <- 'latest'
  }
  cntnr <- paste0(prgrm, '_', nps)
  c('img' = img, 'cntnr' = cntnr, 'tag' = tag)
}

# Conversion ----
#' @name repo_to_img
#' @title Convert repo to image
#' @description Drops .. in repo name to meet docker name requirements and
#' looks up Docker username from package description.
#' @param repo Repo
#' @return Logical
#' @family private-ids
repo_to_img <- function(repo) {
  pkgnm <- repo_to_pkgnm(repo = repo)
  pkgnm_to_img(pkgnm = pkgnm)
}

#' @name pkgnm_to_img
#' @title Convert pkgnm to image
#' @description Drops .. in repo name to meet docker name requirements.
#' @param pkgnm Package name
#' @param docker_user Docker username, if not supplied will search package
#' description.
#' @return Logical
#' @family private-ids
pkgnm_to_img <- function(pkgnm, docker_user = NULL) {
  if (is.null(docker_user)) {
    docker_user <- utils::packageDescription(pkg = pkgnm)[['Docker']]
  }
  img <- gsub(pattern = '\\.\\.', replacement = '_', x = pkgnm)
  img <- sub(pattern = '_[^_]+$', replacement = '', x = img)
  paste0(docker_user, '/', img)
}

#' @name pkgnm_to_repo
#' @title Convert pkgnm to repo
#' @description Converts the R package name of a module into its repo name.
#' @param pkgnm Package name
#' @return Logical
#' @family private-ids
pkgnm_to_repo <- function(pkgnm) {
  prts <- strsplit(x = pkgnm, split = '\\.\\.')[[1]]
  paste0(prts[[length(prts)]], '/', paste0(prts[-1*length(prts)],
                                           collapse = '..'))
}

#' @name repo_to_pkgnm
#' @title Convert repo to pkgnm
#' @description Converts the repo name of a module into its R package name.
#' @param repo Repo
#' @return Logical
#' @family private-ids
repo_to_pkgnm <- function(repo) {
  repo <- tolower(repo)
  is_repo_name(x = repo)
  prts <- strsplit(x = repo, split = '/')[[1]]
  paste0(prts[[2]], '..', prts[[1]])
}

#' @name pkgnm_to_prgm
#' @title Convert pkgnm to prgm
#' @description Converts the R package name of a module into its base program
#' name.
#' @param pkgnm Package name.
#' @return Logical
#' @family private-ids
pkgnm_to_prgm <- function(pkgnm) {
  prts <- strsplit(x = pkgnm, split = '\\.\\.')[[1]]
  prts[[2]]
}

# Check ----
#' @name is_repo_name
#' @title Is GitHub repo name valid?
#' @description Calls error if repo name is invalid.
#' @param x Target name
#' @return NULL
#' @family private-ids
is_repo_name <- function(x) {
  is_repo <- grepl(pattern = '/', x = x) & !grepl(pattern = '\\s', x = x)
  if (!is_repo) {
    stop(char(x), ' is not a valid repo name.', call. = FALSE)
  }
}
