#' @name available
#' @title Look-up available programs for installation
#' @description Returns a data.frame listing all available external programs
#' that can be installed with \code{outsider}.
#' @param pattern REGEX to limit returns
#' @details Limit the names of programs returned using the \code{pattern}
#' argument.
#' @return data.frame
#' @family user
available <- function(pattern=NULL) {
  NULL
}

#' @name install
#' @title Install an outsider module
#' @description 
#' @param id Program ID
#' @return NULL
#' @family user
install <- function(id) {
  if (!is_docker_available()) {
    stop('Docker is not available. Have you installed it? And is it running?')
  }
  if (!build_status(id = id)) {
    mntnr <- sub(pattern = '/.*', replacement = '', x = id)
    msg <- paste0('Sorry, it looks like ', char(id), ' is not passing',
                  ' -- will not attempt to build on your system.',
                  'Try contacting ', char(mntnr), ' for help.')
    stop(msg)
  }
  module_install(repo = id)
}

#' @name remove
#' @title Uninstall and remove a program
#' @description Uninstalls a program and removes it from your docker
#' @param id Program ID
#' @details If program is successfully removed from your Docker, TRUE is
#' returned else FALSE.
#' @return Logical
#' @family user
remove <- function(id) {
  NULL
}
