library("autocorr")

set.seed(9999)

stat_gp()

dat <- sim_2x2_sin(48, 48, rep(0, 4), c(3, 3), c(1, 1))

res <- fit_2x2_sin(dat)

res
