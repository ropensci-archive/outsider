#' @name %program_name%
#' @title %program_name%
#' @description Run %program_name%
#' @param ... Arguments
#' @example /examples/example.R
#' @export
%program_name% <- function(...) {
  # convert the ... into a argument list
  arglist <- outsider::.arglist_get(...)
  # create an outsider object: describe the arguments and program
  otsdr <- outsider::.outsider_init(repo = '%repo%',
                                    cmd = '%program_name%',
                                    arglist = arglist)
  # run the command
  outsider::.run(otsdr)
}
