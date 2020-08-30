suppressMessages({
  library("autocorr")
  library("mgcv")
})

## check use of factor smooth parameter m=1 versus default (no regularization)

fit_m <- function(dat, cs) {
  if (cs) {
    m_gamm <- bam(Y_r ~ A_c * B_c +
                      s(subj_id, A_c, bs = "re") +
                      s(tnum_r, bs = "tp") +
                      s(tnum_r, subj_id, bs = "fs", m = 1),
                    data = dat)
  } else {
    m_gamm <- bam(Y_r ~ A_c * B_c +
                      s(subj_id, A_c, bs = "re") +
                      s(tnum_r, subj_id, bs = "fs", m = 1),
                    data = dat)
  }
  m_gamm_s <- summary(m_gamm)
  v <- c(coef(m_gamm)[1:4],
         sqrt(diag(vcov(m_gamm)[1:4, 1:4])),
         m_gamm_s[["p.table"]][, "Pr(>|t|)"],
         AIC(m_gamm))
  vn <- c("e_int", "e_A", "e_B", "e_AB",
          "se_int", "se_A", "se_B", "se_AB",
          "p_int", "p_A", "p_B", "p_AB",
          "AIC")
  names(v) <- vn
  v
}

mcsim2 <- function(
                   nmc, n_subj = 48L, n_obs = 48L, A = 0, B = 0, AB = 0, 
                   rint_range = blst_quantiles()[, "subj_int"],
                   rslp_range = blst_quantiles()[, "subj_slp"],
                   rcorr_range = c(-0.8, 0.8), version = 0L, 
                   outfile = sprintf("ckm_%05d_%03d_%03d_%0.2f_%0.2f_%0.2f_%0.2f_%0.2f_%0.2f_%0.2f_%d_%s_%s_%s.rds", 
                                     nmc, n_subj, n_obs, A, B, AB,
                                     rint_range[1], rint_range[2], 
                                     rslp_range[1], rslp_range[2],
                                     version,
                                     format(Sys.time(), 
                                            "%Y-%m-%d-%H-%M-%S"),
                                     Sys.info()[["nodename"]], Sys.getpid())) {
  tfile <- tempfile(fileext = ".csv")
  cs <- version %in% c(2L, 7L, 8L)
  lx_append <- FALSE
  for (i in seq_len(nmc)) {
    rint <- runif(1, rint_range[1], rint_range[2])
    rslp <- runif(1, rslp_range[1], rslp_range[2])
    rcorr <- runif(1, rcorr_range[1], rcorr_range[2])
    dat <- sim_2x2(n_subj, n_obs, 0, A, B, AB, rint, rslp, 
                   rcorr, version)
    
    res <- fit_m(dat, cs)
    vv <- c(rint, rslp, rcorr, res)
    readr::write_csv(as.data.frame(as.list(vv)), tfile, append = lx_append, 
                     col_names = FALSE)
    lx_append <- TRUE
  }
  cnames <- paste0("G.r.", names(res))
                   
  ff <- readr::read_csv(tfile, c("rint", "rslp", "rcorr", cnames), 
                        col_types = readr::cols(.default = readr::col_double()))
  file.remove(tfile)
  if (!is.null(outfile)) {
    saveRDS(ff, outfile)
    message(outfile)
  } else {
    invisible(ff)
  }
}

if (!interactive()) {
  args <- as.numeric(commandArgs(TRUE))
  if (length(args) != 5L) {
    stop("usage: Rscript check_m.R nmc A B AB version")
  }
} else {
  args <- c(3L, 0, 0, 0, 2L)
}

suppressMessages(mcsim2(args[1], A = args[2], B = args[3], AB = args[4], version = args[5]))

