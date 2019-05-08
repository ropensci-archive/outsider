#' @name address_unpack
#' @title Unpack repo address
#' @description Returns a list of all the elements that make up a repository
#' address (service, username, repo, ref).
#' @param username Username of repo
#' @param repo Repository address
#' @return list
address_unpack <- function(repo) {
  # defaults to GitHub and master
  raise_error <- function() {
    msg <- paste0("Invalid ", char("repo"), " provided. Must be of the form: ",
                  char("[service]/[username]/[repo]:[ref]"))
    stop(msg, call. = FALSE)
  }
  repo_address <- tolower(repo)
  split1 <- strsplit(x = repo_address, split = '/')[[1]]
  if (length(split1) == 2) {
    service <- 'github'
    username <- split1[[1]]
    repo <- split1[[2]]
  } else if (length(split1) == 3) {
    service <- split1[[1]]
    username <- split1[[2]]
    repo <- split1[[3]]
  } else {
    raise_error()
  }
  split2 <- strsplit(x = repo, split = ':')[[1]]
  if (length(split2) == 1) {
    ref <- 'master'
  } else if (length(split2) == 2) {
    repo <- split2[[1]]
    ref <- split2[[2]]
  } else {
    raise_error()
  }
  list('repo' = repo, 'username' = username, 'ref' = ref, 'service' = service)
}

#' @name pkgnm_guess
#' @title Guess package name
#' @description Return package name from a repo name.
#' @param repo Repository (e.g. "username/repo") associated with module
#' @details Raises error if no module discovered.
#' @return character(1)
pkgnm_guess <- function(repo, call_error = TRUE) {
  mdls <- modules_list()
  metas <- lapply(X = mdls, FUN = meta_get)
  # TODO: expand for more detection
  pull <- vapply(X = metas, FUN = function(x) {
    !is.null(x[['url']]) && grepl(pattern = repo, x = x[['url']],
                                  ignore.case = TRUE)
  }, FUN.VALUE = logical(1))
  if (sum(pull) == 1) {
    res <- mdls[pull]
  } else {
    if (call_error) {
      stop(paste0('No module associated with ', char(repo), ' could be found.'),
           call. = FALSE)
    }
    res <- NULL
  }
  res
}
