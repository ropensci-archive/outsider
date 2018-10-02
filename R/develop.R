#' @name .run
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param ... Command and arguments
#' @return Logical
#' @export
.run <- function(pkgnm, files_to_send, files_to_retrieve, ...) {
  ids <- .ids_get(pkgnm = pkgnm)
  # launch container
  .docker_start(cntnr_id = ids[['cntnr_id']], img_id = ids[['img_id']])
  copy_to_docker(cntnr_id = ids[['cntnr_id']], cntnr_dir = , host_flpths)
  on.exit(.docker_stop(cntnr_id = ids[['cntnr_id']]))
  # run command
  invisible(.docker_exec(cntnr_id = ids[['cntnr_id']], ...))
}

.which_args_are_filepaths <- function(args) {
  files_and_folders <- vapply(X = args, FUN = function(x) file.exists(x) ||
                                dir.exists(x), FUN.VALUE = logical(1))
  names(files_and_folders)[files_and_folders]
}

copy_to_docker <- function(cntnr_id, cntnr_dir, host_flpths) {
  for (host_flpth in host_flpths) {
    outsider::.docker_cp(origin = host_flpth,
                         dest = paste0(cntnr_id, ':', cntnr_dir))
  }
}

copy_from_docker <- function(cntnr_id, host_dir, cntnr_flpths) {
  for (cntnr_flpth in cntnr_flpths) {
    outsider::.docker_cp(origin = host_flpth,
                         dest = paste0(cntnr_id, ':', cntnr_dir))
  }
}

args_check <- function(arg_vctr) {
  if (any(grepl(pattern = '\\s', x = arg_vctr))) {
    msg <- paste0('Arguments should be separate elements without spaces.\n',
                  'e.g. c("-a", "1", "-d", "2"), not "-a 1 -d 2"')
    stop(msg, .call = FALSE)
  }
}

