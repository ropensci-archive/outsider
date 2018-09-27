ids_get <- function(pkgnm) {
  repo <- pkgnm_to_repo(pkgnm)
  prgrm <- pkgnm_to_prgm(pkgnm)
  nps <- docker_ps_count()
  cntnr_id <- paste0(prgrm, '_', nps)
  c('img_id' = repo, 'cntnr_id' = cntnr_id)
}

pkgnm_to_repo <- function(pckgnm) {
  prts <- strsplit(x = pckgnm, split = '\\.\\.')[[1]]
  paste0(prts[[2]], '/', prts[[1]])
}

repo_to_pkgnm <- function(repo) {
  prts <- strsplit(x = repo, split = '/')[[1]]
  paste0(prts[[2]], '..', prts[[1]])
}

pkgnm_to_prgm <- function(pckgnm) {
  prts <- strsplit(x = pckgnm, split = '\\.\\.')[[1]]
  prts[[1]]
}