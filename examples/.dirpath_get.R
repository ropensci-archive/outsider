library(outsider)
# get the parent directory from a filepath
drpth <- tempdir()
flpth <- file.path(drpth, 'testfile')
file.create(flpth)
(.dirpath_get(flpth = flpth) == drpth)
(.dirpath_get(flpth = drpth) == drpth)
file.remove(flpth)
