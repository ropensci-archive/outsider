#' outsider
#'
#'
#'
#' @docType package
#' @name outsider
NULL

.run <- function(pkgnm, ...) {
  ids <- .ids_get(pkgnm = pkgnm)
  # launch container
  .docker_start(cntnr_id = ids[['cntnr_id']], img_id = ids[['img_id']])
  on.exit(.docker_stop(cntnr_id = ids[['cntnr_id']]))
  # run command
  invisible(.docker_exec(cntnr_id = ids[['cntnr_id']], ...))
}