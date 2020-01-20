# precompile
library(knitr)
vgnts <- c('phylogenetic_pipeline.Rmd', 'outsider.Rmd')
for (vgnt in vgnts) {
  knit(paste0("vignettes/", vgnt, ".orig"), paste0("vignettes/", vgnt))
}

# TODO: fix figure link, spinning icon

library(devtools)
build_vignettes()