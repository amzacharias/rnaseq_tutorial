#!/usr/bin/env Rscript
# -*-coding: utf-8 -*-
#-----------------------------------------------
# Title: Differential expression analysis
# Author: Amanda Zacharias
# Date: 2026-07-03
# Email: 16amz1@queensu.ca
# Notes -----------------------------------------------
# module load StdEnv/2023 r/4.5.0

# Options -----------------------------------------------

# Packages -----------------------------------------------
library(edgeR) # v4.6.3
library(dplyr) # v1.2.0
library(tibble) # v3.3.0
library(ggplot2) # v3.4.0

# Pathways -----------------------------------------------
## Inputs ===========
prep_dir <- "5_data_prep"
dataframes_dir <- file.path(prep_dir, "dataframes")
counts_path <- file.path(dataframes_dir, "clean_counts.csv")
id2name_path <- file.path(dataframes_dir, "id2name.csv")
coldata_path <- file.path(dataframes_dir, "clean_coldata.csv")

rdata_dir <- file.path(prep_dir, "rdata")
genes_to_keep_path <- file.path(rdata_dir, "genes_to_keep.rds")

## Outputs ===========
dea_dir <- "6_dea"
dataframes_dir <- file.path(dea_dir, "dataframes")
figures_dir <- file.path(dea_dir, "figures")
rdata_dir <- file.path(dea_dir, "rdata")

# Create the output directories using R instead of unix.
dir.create(dataframes_dir)
dir.create(figures_dir)
dir.create(rdata_dir)

# Load data -----------------------------------------------
counts <- read.csv(counts_path, row.names = 1)
coldata <- read.csv(coldata_path, row.names = 1)
id2name <- read.csv(id2name_path, row.names = 1)
genes_to_keep <- readRDS(genes_to_keep_path)

# Refactor our experimental condition of interest to be a factor -----------------------------------
coldata$time # time before factorization
coldata$time <- factor(coldata$time, levels = c("dawn", "dusk"))
coldata$time # time after factorization

# Prepare objects -----------------------------------------------
dge <- DGEList(counts = counts)
design <- model.matrix(~ time, data = coldata)
head(design)

# Save design
write.csv(design, file.path(dataframes_dir, "design.csv"))

# EdgeR workflow -----------------------------------------------
# Normalize counts
dge <- calcNormFactors(dge, method = "TMM")

# Estimate disperion
dge <- estimateDisp(dge, design)

# Filtering
dge_filt <- dge[genes_to_keep, ]

# Fit the model
fit <- glmQLFit(dge_filt, design)

# Testing
qlf <- glmQLFTest(fit, coef = "timedusk")

# Get results -----------------------------------------------
results <- topTags(qlf, n = Inf, adjust.method = "BH", sort.by = "PValue")
results_df <- results$table
results_id2name <- results_df |>
  tibble::rownames_to_column(var = "gene_name") |>
  dplyr::left_join(id2name, by = "gene_name")

sig_results <- results_id2name |>
  dplyr::filter(FDR < 0.05)
cat("\nNumber of genes tested: ", nrow(results_df), "\n") # 28999
cat("\nNumber of significant genes (FDR < 0.05): ", nrow(sig_results), "\n") # 4

# Save the results -----------------------------------------------
write.csv(results_id2name, file.path(dataframes_dir, "all_results.csv"))
write.csv(sig_results, file.path(dataframes_dir, "sig_results.csv"))

# Plot results -----------------------------------------------
# Add a column to indicate significance
plot_data <- results_id2name |>
  dplyr::mutate(significance = ifelse(FDR < 0.05, "Significant", "Not Significant"))

bh_threshold <- max(sig_results$PValue)

volcano_plot <- plot_data |>
  ggplot(aes(x = logFC, y = -log10(PValue), colour = significance)) +
  geom_point(alpha = 0.5) +
  scale_colour_manual(
    name = "Significance",
    values = c("Significant" = "red", "Not Significant" = "black")
  ) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  geom_hline(yintercept = -log10(bh_threshold), linetype = "dotdash") +
  xlab("Log2 Fold Change") +
  ylab("-Log10 P-Value") +
  theme_bw()
volcano_plot

ggsave(
  plot = volcano_plot, path = figures_dir,
  filename = "volcano_plot.png",
  width = 180, height = 180, units = "mm"
)

# Save environment -----------------------------------------------
save.image(file.path(rdata_dir, "dea.RData"))
