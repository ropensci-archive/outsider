# Install the rOpenSci theme
remotes::install_github("ropensci/rotemplate")

# Run in your package directory to build the site:
template <- list(package = "rotemplate")
pkgdown::build_site(override = list(template = template))

pkgdown::build_articles(override = list(template = template))
