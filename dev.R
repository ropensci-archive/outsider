

flpth <- '/home/dom/Desktop/cmdr'
lbpth <- file.path(flpth, 'lib')

url <- 'ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz'
download.file(url = url, destfile = file.path(lbpth, 'blast'))

sys::exec_wait(cmd = 'tar', args = c('zxf', file.path(lbpth, 'blast'), '-C',
                                     lbpth))
file.remove(file.path())
sys::exec_wait(cmd = 'mv', args = c('zxf', file.path(lbpth, 'blast'), '-C',
                                     lbpth))


cmd <- file.path(lbpth, 'blastn')
