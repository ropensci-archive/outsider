#' @name .run
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param files_to_send Filepaths on host to send to module container
#' @param ... Command and arguments
#' @return Logical
#' @export
.run <- function(pkgnm, files_to_send, ...) {
  ids <- .ids_get(pkgnm = pkgnm)
  # launch container
  .docker_start(cntnr_id = ids[['cntnr_id']], img_id = ids[['img_id']])
  # close container after function has completed
  on.exit(.docker_stop(cntnr_id = ids[['cntnr_id']]))
  # copy files_to_send to container
  .copy_to_docker(cntnr_id = ids[['cntnr_id']], host_flpths = files_to_send)
  # run command
  success <- .docker_exec(cntnr_id = ids[['cntnr_id']], ...)
  # retrieve files
  .copy_from_docker(cntnr_id = ids[['cntnr_id']])
  invisible(success)
}

#' @name .args_parse
#' @title Parse arguments
#' @description Parse arguments.
#' @param ... Command and arguments
#' @return Character vector
#' @export
.args_parse <- function(...) {
  args <- unlist(as.list(match.call())[-1])
  if (any(grepl(pattern = '\\s', x = args))) {
    msg <- paste0('Arguments should be separate elements without spaces.\n',
                  'e.g. c("-a", "1", "-d", "2"), not "-a 1 -d 2"')
    stop(msg, .call = FALSE)
  }
  args
}

#' @name .which_args_are_filepaths
#' @title Determine which args are filepaths
#' @description Return filepaths from args.
#' @param args Character vector of arguments
#' @return Character vector
#' @export
.which_args_are_filepaths <- function(args) {
  files_and_folders <- vapply(X = args, FUN = function(x) file.exists(x) ||
                                dir.exists(x), FUN.VALUE = logical(1))
  names(files_and_folders)[files_and_folders]
}

.copy_to_docker <- function(cntnr_id, host_flpths) {
  for (host_flpth in host_flpths) {
    outsider::.docker_cp(origin = host_flpth,
                         dest = paste0(cntnr_id, ':', '/working_dir/'))
  }
}

.copy_from_docker <- function(cntnr_id) {
  outsider::.docker_cp(origin = paste0(cntnr_id, ':', '/working_dir/.'),
                       dest = '.')
}

args_check <- function(arg_vctr) {
  
}

.travis.yml_gen <- function(repo) {
  url <- paste0('https://raw.githubusercontent.com/DomBennett/',
                'om..hello.world..1.0/master/.travis.yml')
  travis_text <- paste0(readLines(url), collapse = '\n')
  travis_text <- sub(pattern = 'DomBennett/om\\.\\.hello\\.world\\.\\.1\\.0',
                     replacement = repo, x = travis_text)
  write(x = travis_text, file = '.travis.yml')
}