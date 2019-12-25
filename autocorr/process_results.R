suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("tidyr"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("ggplot2"))

my_path <-
  if (interactive()) {
    "."
  } else {
    if (length(commandArgs(TRUE)))
      commandArgs(TRUE)[1]
    else
      "."
  }

getdata <- function(x) {
  readRDS(file.path(my_path, x)) %>%
  select(G.r.p_A, G.r.p_B, G.r.p_AB,
	 G.b.p_A, G.b.p_B, G.b.p_AB,
	 L.r.p_A, L.r.p_B, L.r.p_AB,
	 L.b.p_A, L.b.p_B, L.b.p_AB) %>%
  pivot_longer(G.r.p_A:L.b.p_AB, names_to = "version") %>%
  separate(version, c("model", "rb", "effect"), "\\.")
}

allfiles <- dir(my_path, "^ac.*\\.rds$")

if (length(allfiles) == 0L) {
  stop("No output files found in ",
       if (my_path == ".") "current path" else my_path)
}

message("Processing ", length(allfiles), " output files...")

alldat <- tibble(fname = allfiles) %>%
  separate(fname, c("j", "nmc", "ns", "nobs", "A", "B", "AB",
		    "ri0", "ri1", "rs0", "rs1", "version",
		    "date", "host", "pid"), "_",
	   remove = FALSE, convert = TRUE) %>%
  mutate(dat = map(fname, getdata)) %>%
  unnest(c(dat)) %>%
  mutate(sig = value < .05,
	 factor = factor(sub("^p_", "", effect), levels = c("A", "B", "AB")),
	 model = factor(if_else(model == "G", "GAMM", "LMEM")),
	 effsize = as.numeric(case_when(factor == "A" ~ A,
					factor == "B" ~ B,
					TRUE ~ AB)),
	 allocation = if_else(rb == "r", "randomized", "blocked"))

cases <- tibble(version = 2:9,
		case = factor(c("1. varying phase",
				"2. varying amp",
				"3. random walk 1",
				"4. random walk 2",
				"5. multi 1 + 3",
				"6. multi 1 + 4",
				"7. multi 2 + 3",
				"8. multi 2 + 4")))

control <- alldat %>%
  filter(version == 1L) %>%
  group_by(ns, nobs, effsize, factor, allocation) %>%
  summarize(psig = mean(sig), N = n()) %>%
  ungroup()

ctrlA <- control %>% filter(factor == "A")
ctrlB <- control %>% filter(factor == "B")
ctrlAB <- control %>% filter(factor == "AB")

mstats <- alldat %>%
  filter(version != 1L) %>%
  inner_join(cases, "version") %>%
  group_by(ns, nobs, effsize, case, model, allocation, factor) %>%
  summarize(psig = mean(sig), N = n()) %>%
  ungroup() %>%
  arrange(allocation, effsize, case, factor, model) 

effA <- ggplot(
  mstats %>% filter(factor == "A"),
  aes(effsize, psig)) +
  geom_point(aes(color = model, shape = model), alpha = .5) +
  geom_line(aes(color = model), alpha = .5) +
  geom_line(data = ctrlA, alpha = .2, linetype = 3) +
  scale_x_continuous(breaks = seq(0, .25, .05)) +
  coord_cartesian(ylim = c(0, 1), xlim = c(0, .25)) +
  facet_grid(allocation ~ case) +
  theme(legend.position = "top",
	legend.margin = margin(0, 0, 0, 0),
	legend.box.margin = margin(-5, 0, -5, 0),        
	axis.text.x = element_text(size = 5),
	axis.text.y = element_text(size = 7)) +
  labs(x = "raw effect", y = "proportion significant")

effB <- ggplot(
  mstats %>% filter(factor == "B"),
  aes(effsize, psig)) +
  geom_point(aes(color = model, shape = model), alpha = .5) +
  geom_line(aes(color = model), alpha = .5) +
  geom_line(data = ctrlB, alpha = .2, linetype = 3) +
  scale_x_continuous(breaks = seq(0, .5, .1)) +
  coord_cartesian(ylim = c(0, 1), xlim = c(0, .5)) +  
  facet_grid(allocation ~ case) +
  theme(legend.position = "top",
	legend.margin = margin(0, 0, 0, 0),
	legend.box.margin = margin(-5, 0, -5, 0),        
	axis.text.x = element_text(size = 7),
	axis.text.y = element_text(size = 7)) +
  labs(x = "raw effect", y = "proportion significant")

effAB <- ggplot(
  mstats %>% filter(factor == "AB"),
  aes(effsize, psig)) +
  geom_point(aes(color = model, shape = model), alpha = .5) +
  geom_line(aes(color = model), alpha = .5) +
  geom_line(data = ctrlAB, alpha = .2, linetype = 3) +
  scale_x_continuous(breaks = seq(0, .5, .1)) +
  coord_cartesian(ylim = c(0, 1), xlim = c(0, .5)) +  
  facet_grid(allocation ~ case) +
  theme(legend.position = "top",
	legend.margin = margin(0, 0, 0, 0),
	legend.box.margin = margin(-5, 0, -5, 0),        
	axis.text.x = element_text(size = 7),
	axis.text.y = element_text(size = 7)) +
  labs(x = "raw effect", y = "proportion significant")

ggsave("eff_A.png", effA, width = 10, height = 3.3)
ggsave("eff_B.png", effB, width = 10, height = 3.3)
ggsave("eff_AB.png", effAB, width = 10, height = 3.3)
message("wrote files 'eff_A.png', 'eff_B.png', 'eff_AB.png'")
