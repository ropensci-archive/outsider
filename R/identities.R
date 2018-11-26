#' @name ids_get
#' @title Get image ID and unique container ID
#' @description From a pkgnm, return the image ID and a unique container ID.
#' @param pkgnm Package name
#' @return Logical
ids_get <- function(pkgnm) {
  repo <- pkgnm_to_repo(pkgnm)
  img_id <- repo_to_img(repo)
  prgrm <- pkgnm_to_prgm(pkgnm)
  nps <- docker_ps_count()
  cntnr_id <- paste0(prgrm, '_', nps)
  c('img_id' = img_id, 'cntnr_id' = cntnr_id)
}

#' @name repo_to_img
#' @title Convert repo to image ID
#' @description Drops .. in repo name to meet docker name requirements.
#' @param repo Repo
#' @return Logical
repo_to_img <- function(repo) {
  repo <- tolower(repo)
  gsub(pattern = '\\.\\.', replacement = '_', x = repo)
}

#' @name pkgnm_to_repo
#' @title Convert pkgnm to repo
#' @description Converts the R package name of a module into its repo name.
#' @param pkgnm Package name
#' @return Logical
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
repo_to_pkgnm <- function(repo) {
  repo <- tolower(repo)
  prts <- strsplit(x = repo, split = '/')[[1]]
  paste0(prts[[2]], '..', prts[[1]])
}

#' @name pkgnm_to_prgm
#' @title Convert pkgnm to prgm
#' @description Converts the R package name of a module into its base program
#' name.
#' @param pkgnm Package name.
#' @return Logical
pkgnm_to_prgm <- function(pkgnm) {
  prts <- strsplit(x = pkgnm, split = '\\.\\.')[[1]]
  prts[[2]]
}
