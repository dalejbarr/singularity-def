library("autocorr")
library("parallel")

if (file.exists("cluster_setup.R")) {
  source("cluster_setup.R")
} else {
  nCores <- parallel::detectCores() - 2L
  if (nCores < 1L) {
    nCores <- 1L
  }
  cl <- makeCluster(nCores)
}

if (interactive()) {
  params <- c(nmc = 6, within_eff = 10, between_eff = 24)
} else {
  params <- as.numeric(commandArgs(TRUE))
}

res <- parSapply(cl, 1:params[1], function(.x, params) {
  autocorr::simfit_practice_all(within_eff = params[2],
                                between_eff = params[3])
}, params = params)

fname <- sprintf("practice_W%02d_B%02d_N%05d_%s_%s.rds",
                 params[2], params[3], params[1],
                 Sys.info()[["nodename"]],
                 Sys.getpid())

stopCluster(cl)

saveRDS(res, fname)
# message("Simulation results saved to ", fname)
