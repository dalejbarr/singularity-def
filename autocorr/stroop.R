library(autocorr)

if (interactive()) {
  args <- c(nmc = 12L, B1 = 0L, B2 = 120L)
} else {
  args <- as.integer(commandArgs(TRUE)[1:3])
  names(args) <- c("nmc", "B1", "B2")
}

fname <- sprintf("stroop_W%03d_B%03d_%05d_%s_%s.rds",
                 args["B1"], args["B2"], args["nmc"],
                 Sys.info()[["nodename"]],
                 Sys.getpid())

res <- sapply(1:args["nmc"], function(.x, args) {
  dat <- autocorr::simulate_stroop(48, B1 = args["B1"], B2 = args["B2"])
  autocorr::fit_stroop(dat)
}, args)

saveRDS(res, fname)

## apply(res[c("G.p.A", "L.p.A", "G.p.B", "L.p.B"), , drop = FALSE], 1,
##      function(x) {
##        sum(x < .05) / length(x)
##      })
