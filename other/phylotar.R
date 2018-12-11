# Libs ----
library(phylotaR)

# Functions ----
blastdir_get <- function() {
  if (.Platform$OS.type != 'unix') {
    stop('Not a UNIX system')
  }
  res <- sys::exec_internal(cmd = 'which', args = 'blastn')
  outsider::.dirpath_get(rawToChar(res[['stdout']]))
}

# Setup and run ----
wd <- 'beavers'
if (!dir.exists(wd)) {
  dir.create(wd)
}
txid <- 29132
setup(wd = wd, txid = txid, ncbi_dr = blastdir_get(), ovrwrt = TRUE)
run(wd = wd)

# Parse and output
cls <- read_phylota(wd)
summary(cls)
txids <- get_sq_slot(cls, cid = '0', slt_nm = 'txid')
sp_ids <- get_txids(cls, txids = txids, rnk = 'genus')
get_tx_slot(cls, sp_ids, slt_nm = 'scnm')



