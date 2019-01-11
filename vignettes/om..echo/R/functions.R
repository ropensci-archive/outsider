#' @name echo
#' @title echo
#' @description Run echo
#' @param ... Arguments
#' @examples
#' library(outsider)
#' echo <- module_import('echo', repo = 'dombennett/om..echo')
#' echo('-h')  # or --help or whichever argument prints help
#' @export
echo <- function(...) {
  # convert the ... into a argument list
  arglist <- outsider::.arglist_get(...)
  # create an outsider object: describe the arguments and program
  otsdr <- outsider::.outsider_init(repo = 'dombennett/om..echo',
                                    cmd = 'echo',
                                    arglist = arglist)
  # run the command
  outsider::.run(otsdr)
}
