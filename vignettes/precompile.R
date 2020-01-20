# precompile
library(knitr)
vgnts <- c('phylogenetic_pipeline.Rmd', 'outsider.Rmd')
for (vgnt in vgnts) {
  knit(paste0("vignettes/", vgnt, ".orig"), paste0("vignettes/", vgnt))
}

library(devtools)
build_vignettes()