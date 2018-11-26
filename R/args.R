# Private ----
#' @name args_get
#' @title Return the arguments of the parent function
#' @description Expand ... by calling this function.
#' @return List
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


# Public ----
#' @name .arglist_get
#' @title Generate vector of arguments
#' @description Convert all the arguments passed to this function, including
#' those contained in '...', into character vector.
#' @param ... Any number of arguments
#' @return Character vector
#' @export
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
.filestosend_get <- function(arglist, wd = NULL) {
  # Check whether any arglist are filepaths
  arglist <- arglist[arglist != wd]
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
#' @description Utility function for determines the working directory from 
#' arglist. The workign directory can be determined from the arglist either by
#' a key:value or an index. For example, the working directory may be determined
#' by the key \code{-wd} in which case this function will identify whether this
#' key exists in the arglist and will return its corresponding value.
#' If no key or i is provided or found in the arguments, returns the
#' R session's working directory.
#' @param arglist Arguments as character vector
#' @param key Argument key identifying the working directory, e.g. -wd
#' @param i Index of the working directory in the arguments, e.g. 1.
#' @return Character
#' @export
.wd_get <- function(arglist, key = NULL, i = NULL) {
  wd <- getwd()
  if (!is.null(key) && key %in% arglist) {
    wd_i <- which(arglist == key)
    wd <- arglist[wd_i + 1]
    return(wd)
  }
  if (!is.null(i)) {
    wd <- sub(pattern = basename(arglist[i]), replacement = '', x = arglist[i])
    if (wd == '') {
      wd <- getwd()
    }
  }
  wd
}

#' @name .arglist_parse
#' @title Normalise arguments for docker container
#' @description Utility function for parsing the arguments provided by a user.
#' Drop any specified key:value pairs with \code{keyvals_to_drop} or drop any
#' specific values \code{vals_to_drop}. With \code{normalise_paths} as TRUE,
#' all filepaths in the arglist will be converted to basenames.
#' @param arglist Arguments as character vector
#' @param keyvals_to_drop Argument keys to drop, e.g. -wd.
#' @param vals_to_drop Specific values to drop, e.g. --verbose.
#' @return Character vector
#' @export
.arglist_parse <- function(arglist, keyvals_to_drop = NULL, vals_to_drop = NULL,
                           normalise_paths = TRUE) {
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
