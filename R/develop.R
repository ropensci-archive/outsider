#' @name .run
#' @title Run a command from a docker image
#' @description Run a command with arguments within a docker image. The function
#' will start a container, run the command and after completion stop and remove
#' the container.
#' @param pkgnm Package name
#' @param files_to_send Filepaths on host to send to module container
#' @param dest Filepath on host computer for generated files to be returned
#' @param ... Command and arguments
#' @return Logical
#' @export
#' @family developer
.run <- function(pkgnm, files_to_send, dest = getwd(), ...) {
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
  .copy_from_docker(cntnr_id = ids[['cntnr_id']], dest = dest)
  invisible(success)
}

#' @name .args_parse
#' @title Parse arguments
#' @description Parse arguments.
#' @param ... Command and arguments
#' @return Character vector
#' @export
#' @family developer
.args_parse <- function(...) {
  args <- unlist(as.list(match.call())[-1])
  # if (any(grepl(pattern = '\\s', x = args))) {
  #   msg <- paste0('Arguments should be separate elements without spaces.\n',
  #                 'e.g. c("-a", "1", "-d", "2"), not "-a 1 -d 2"')
  #   stop(msg, .call = FALSE)
  # }
  args
}

#' @name .which_args_are_filepaths
#' @title Determine which args are filepaths
#' @description Return filepaths from args.
#' @param args Character vector of arguments
#' @param wd Working directory in which to look for files
#' @return Character vector
#' @export
#' @family developer
.which_args_are_filepaths <- function(args, wd = NULL) {
  # Check whether any args are filepaths
  bool_1 <- is_filepath(args)
  res <- args[bool_1]
  if (!is.null(wd)) {
    # Add to list, any wd + args that are filepaths
    wd_args <- file.path(wd, args)
    bool_2 <- is_filepath(wd_args)
    res <- c(res, wd_args[bool_2])
  }
  res
}

#' @name .to_basename
#' @title Reduce to filepaths to basename
#' @description Return return a vector where all valid filepaths are converted
#' to file basenames. E.g. "dir1/dir2/text.file" is converted to "text.file"
#' @param x Character vector
#' @return Character vector
#' @export
#' @family developer
.to_basename <- function(args) {
  files_and_folders <- is_filepath(args)
  args[files_and_folders] <- basename(args[files_and_folders])
  args
}

#' @name .copy_to_docker
#' @title Copy files to docker container
#' @description Copy all given host files to a running docker container.
#' @param cntnr_id Container ID
#' @param host_flpths Filepaths to send on host computer
#' @return Logical
#' @export
#' @family developer
.copy_to_docker <- function(cntnr_id, host_flpths) {
  res <- TRUE
  for (host_flpth in host_flpths) {
    res <- res & .docker_cp(origin = host_flpth,
                            dest = paste0(cntnr_id, ':', '/working_dir/'))
  }
  res
}

#' @name .copy_from_docker
#' @title Copy all contents from working dir
#' @description Copy all the contents of the working_dir on the outsider Docker
#' container to the host machine.
#' @details All outsider modules have a working_dir/ when generated files are
#' created. These must be copied from the container to the host machine
#' for the user to interact with.
#' @param cntnr_id Container ID
#' @param dest Directory on host computer where files should be sent
#' @return Logical
#' @export
#' @family developer
.copy_from_docker <- function(cntnr_id, dest = getwd()) {
  .docker_cp(origin = paste0(cntnr_id, ':', '/working_dir/.'), dest = dest)
}

#' @name .travisyml_gen
#' @title Generate travis file
#' @description Write .travis.yml to working directory.
#' @details All validated outsider modules must have a .travis.yml in their
#' repository. These .travis.yml must be generated using this function.
#' @param repo Repository
#' @return Logical
#' @export
#' @family developer
.travisyml_gen <- function(repo) {
  url <- paste0('https://raw.githubusercontent.com/DomBennett/',
                'om..hello.world..1.0/master/.travis.yml')
  travis_text <- paste0(readLines(url), collapse = '\n')
  travis_text <- sub(pattern = 'DomBennett/om\\.\\.hello\\.world\\.\\.1\\.0',
                     replacement = repo, x = travis_text)
  write(x = travis_text, file = '.travis.yml')
  invisible(file.exists('.travis.yml'))
}

#' @name is_filepath
#' @title Is a filepath?
#' @description Return TRUE or FALSE for whether character(s) is a valid
#' filepath.
#' @param x Character vector
#' @return Logical
#' @family private
is_filepath <- function(x) {
  unname(vapply(X = x, FUN = function(x) file.exists(x) ||
                  dir.exists(x), FUN.VALUE = logical(1)))
}
