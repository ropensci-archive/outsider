# Developer argument functions

# Private ----
args_get <- function() {
  parent <- sys.parent(n = 1L)
  as.list(match.call(definition = sys.function(parent),
                     call = sys.call(parent)))[-1]
}

#' @name to_basename
#' @title Reduce to filepaths to basename
#' @description Return return a vector where all valid filepaths are converted
#' to file basenames. E.g. "dir1/dir2/text.file" is converted to "text.file"
#' @param x Character vector
#' @return Character vector
#' @family private
to_basename <- function(x) {
  files_and_folders <- is_filepath(x)
  x[files_and_folders] <- basename(x[files_and_folders])
  x
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


# Public (hidden from general user) ----
#' @name .arglist_get
#' @title Generate vector of arguments
#' @description Convert all the arguments passed to this function, including
#' those contained in '...', into character vector.
#' @param ... Any number of arguments
#' @return Character vector
#' @export
#' @family developer
.arglist_get <- function(...) {
  arglist <- args_get()
  arglist <- lapply(X = arglist, FUN = eval)
  arglist <- vapply(X = arglist, FUN = as.character, FUN.VALUE = character(1))
  arglist
}

#' @name .filestosend_get
#' @title Determine which arguments are filepaths
#' @description Return filepaths from arguments. These filepaths can then be
#' used to identify files/folders for sending to the Docker container.
#' @param arglist Character vector of arguments
#' @param wd Working directory in which to look for files
#' @return Character vector
#' @export
#' @family developer
.filestosend_get <- function(arglist, wd = NULL) {
  if (length(arglist) == 0) {
    return(character(0))
  }
  # Check whether any arglist are filepaths
  if (!is.null(wd)) {
    arglist <- arglist[arglist != wd]
  }
  bool_1 <- is_filepath(arglist)
  res <- arglist[bool_1]
  if (!is.null(wd)) {
    # Add to list, any wd + arglist that are filepaths
    wd_args <- file.path(wd, arglist)
    bool_2 <- is_filepath(wd_args)
    res <- c(res, wd_args[bool_2])
  }
  res
}

#' @name .wd_get
#' @title Return working directory
#' @description Utility function for determining the working directory from 
#' arglist. The working directory can be determined from the arglist either by
#' a key:value or an index. For example, the working directory may be determined
#' by the key \code{-wd} in which case this function will identify whether this
#' key exists in the arglist and will return its corresponding value.
#' Alternatively, the working directory may be determined by the first argument
#' (e.g. an input file), in which case setting \code{i=1} will return the first
#' argument in the arglist.
#' If an input file is returned, a user can use \link{\code{.dirpath_get}} to
#' convert the file path to a directory path.
#' If both \code{key} and \code{i} are provided, \code{key} takes precedence.
#' If no \code{key} or \code{i} is provided and/or no working directory is
#' found in the arguments, the function will return the R session's working
#' directory.
#' If no arguments are provided, returns empty character vector.
#' @param arglist Arguments as character vector
#' @param key Argument key identifying the working directory, e.g. -wd
#' @param i Index in the arglist that determines the working directory, e.g. 1.
#' @return Character
#' @export
#' @family developer
.wd_get <- function(arglist, key = NULL, i = NULL) {
  if (length(arglist) == 0) {
    return(character(0))
  }
  wd <- getwd()
  if (!is.null(key) && key %in% arglist) {
    wd_i <- which(arglist == key)
    wd <- arglist[wd_i + 1]
    return(wd)
  }
  if (!is.null(i)) {
    wd <- arglist[[i]]
  }
  wd
}

#' @name .dirpath_get
#' @title Convert file path to directory path
#' @description Takes a file path and converts it to its directory path by
#' dropping the file name and extension. If \code{flpth} is already a directory
#' path, the argument will be returned unchanged. If nothing is provided,
#' nothing is returned (i.e. \code{character(0)}).
#' @param flpth File path for which directory path will be returned.
#' @return Character
#' @export
#' @family developer
.dirpath_get <- function(flpth) {
  if (length(flpth) == 0) {
    return(character(0))
  }
  if (dir.exists(flpth)) {
    # already a directory
    return(flpth)
  }
  res <- sub(pattern = basename(flpth), replacement = '', x = flpth)
  if (res == '') {
    # if no path, must be working directory
    res <- getwd()
  }
  res
}

#' @name .arglist_parse
#' @title Normalise arguments for docker container
#' @description Utility function for parsing the arguments provided by a user.
#' Drop any specified key:value pairs with \code{keyvals_to_drop} or drop any
#' specific values \code{vals_to_drop}. With \code{normalise_paths} as TRUE,
#' all filepaths in the arglist will be converted to basenames.
#' @details It is important the file paths are normalised, because they will
#' not be available to the Docker container. The only files available will
#' be those that have been transfered to the container as determined through
#' the \link{\code{.outsider_init}}. These files will be located in the
#' same directory as where the function is called and require no absolute
#' file path.
#' @param arglist Arguments as character vector
#' @param keyvals_to_drop Argument keys to drop, e.g. -wd.
#' @param vals_to_drop Specific values to drop, e.g. --verbose.
#' @return Character vector
#' @export
#' @family developer
.arglist_parse <- function(arglist, keyvals_to_drop = NULL, vals_to_drop = NULL,
                           normalise_paths = TRUE) {
  if (length(arglist) == 0) {
    return(character(0))
  }
  for (each in keyvals_to_drop) {
    if (each %in% arglist) {
      each_i <- which(arglist == each)
      arglist <- arglist[-1 * c(each_i, each_i + 1)]
    }
  }
  for (each in vals_to_drop) {
    if (each %in% arglist) {
      each_i <- which(arglist == each)
      arglist <- arglist[-1 * c(each_i)]
    }
  }
  if (normalise_paths) {
    arglist <- to_basename(arglist)
  }
  arglist
}
