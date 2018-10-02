#' @name .run
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param ... Command and arguments
#' @return Logical
#' @export
.run <- function(pkgnm, ...) {
  ids <- .ids_get(pkgnm = pkgnm)
  # launch container
  .docker_start(cntnr_id = ids[['cntnr_id']], img_id = ids[['img_id']])
  on.exit(.docker_stop(cntnr_id = ids[['cntnr_id']]))
  # run command
  invisible(.docker_exec(cntnr_id = ids[['cntnr_id']], ...))
}