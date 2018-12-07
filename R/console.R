# Control messaging to console

.onAttach <- function(...) {
  default_log_set()
}

char <- function(x) {
  crayon::green(encodeString(x, quote = "'"))
}

stat <- function(...) {
  crayon::blue(...)
}

func <- function(x) {
  crayon::red(paste0(x, '()'))
}

cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}

celebrate <- function() {
  template <- paste0("${Exclamation}!", " The module works!",
                     " You are ${adjective}!")
  mssg <- praise::praise(template = template)
  cat_line(crayon::green(mssg))
}

comfort <- function() {
  phrases <- c('Ah shucks....', 'Damn damn damn.', 'Sodding socks.',
               'Well drop the goat. This is not great.',
               'Grrrr.....', 'A truly unfavourable circumstance:',
               'I am sorry. I feel bad.')
  template <- "But keep on ${creating}! You're doing ${adverb_manner}!"
  mssg <- paste0(sample(phrases, 1), " The module is not working....\n",
                 praise::praise(template = template))
  cat_line(crayon::blue(mssg))
}
