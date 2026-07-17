#!/usr/bin/env Rscript
# -*-coding: utf-8 -*-
#-----------------------------------------------
# Title: Enrichment analysis with gprofiler
# Author: Amanda Zacharias
# Date: 2026-07-03
# Email: 16amz1@queensu.ca
# Notes -----------------------------------------------
# module load StdEnv/2023 r/4.5.0

# Options -----------------------------------------------

# Packages -----------------------------------------------
library(gprofiler2)
library(ggplot2)

# Pathways -----------------------------------------------
## Input ===========
dea_dir <- "6_dea"
sig_results_path <- file.path(dea_dir, "dataframes", "sig_results.csv")

## Output ===========
enrich_dir <- "7_enrichment"
dataframes_dir <- file.path(enrich_dir, "dataframes")
figures_dir <- file.path(enrich_dir, "figures")
rdata_dir <- file.path(enrich_dir, "rdata")

dir.create(dataframes_dir)
dir.create(figures_dir)
dir.create(rdata_dir)

# Load data -----------------------------------------------
dea_res <- read.csv(sig_results_path, row.names = 1)
head(dea_res)

# Run G:profiler -----------------------------------------------
gost_res <- gost(
  query = dea_res$gene_name,
  organism = "mmusculus",
  correction_method = "g_SCS",
  domain_scope = "annotated"
)

gost_link <- gost(
  query = dea_res$gene_name,
  organism = "mmusculus",
  correction_method = "g_SCS",
  domain_scope = "annotated",
  as_short_link = TRUE
)

# Get results -----------------------------------------------
gost_res_df <- gost_res$result |> as.data.frame()
res_df_chr <- apply(gost_res_df, 2, as.character)

# Save results -----------------------------------------------
saveRDS(gost_res, file = file.path(rdata_dir, "gost_res.rds"))
write.csv(res_df_chr, file.path(dataframes_dir, "gprofiler_results.csv"))
write.table(
  gost_link, file.path(dataframes_dir, "gprofiler_link.txt"),
  row.names = FALSE, col.names = FALSE
)

# Plot results -----------------------------------------------
bubble_plot <- gost_df |>
  # subset(term_size > 100 & term_size < 500) |> # optionally subset by term size
  head(n = 10) |>
  ggplot(aes(x = intersection_size / term_size, y = term_name)) +
  geom_point(aes(size = intersection_size, colour = -log10(p_value))) +
  xlab("overlap / term size") +
  ylab("term") +
  scale_colour_continuous(name = "-log10(adj. p)") +
  scale_size_continuous(name = "overlap") +
  theme_bw()
bubble_plot

ggsave(
  plot = bubble_plot,
  path = figures_dir,
  filename = "bubble_plot.pdf",
  width = 90,
  height = 90,
  units = "mm"
)

# Save RData -----------------------------------------------
save.image(file = file.path(rdata_dir, "gprofiler.RData"))
