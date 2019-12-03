if (length(commandArgs(TRUE)) != 4) {
  stop("Need to supply 4 arguments to the script (A, B, AB, num_runs).")
}

if (interactive()) {
  prefix <- "test"
} else {
  cargs <- commandArgs()
  prefix <- basename(sub("^--file=(.*)\\.R$", "\\1", grep("^--file=", cargs, value = TRUE)))
}

host <- Sys.info()[["nodename"]]
pid <- Sys.getpid()

## fixed effects (all zeros for H0 true)
feff <- as.numeric(commandArgs(TRUE)[1:3])
num_runs <- as.integer(commandArgs(TRUE)[4])

fbase <- sprintf("%s_%0.2f_%0.2f_%0.2f_%05d_%s_%d.rds",
		 prefix, feff[1], feff[2], feff[3], num_runs, host, pid)

saveRDS(rnorm(5), fbase)
cat(fbase, "\n", sep = "")
