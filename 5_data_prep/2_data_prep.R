#!/usr/bin/env Rscript
# -*-coding: utf-8 -*-
#-----------------------------------------------
# Title: Outlier detection
# Author: Amanda Zacharias
# Date: 2026-07-03
# Email: 16amz1@queensu.ca
# Notes -----------------------------------------------
# module load StdEnv/2023 r/4.5.0

# Options -----------------------------------------------

# Packages -----------------------------------------------
library(DESeq2)
library(ggplot2)
library(edgeR)

# Pathways -----------------------------------------------
## Input ===========
dataframes_dir <- file.path("5_data_prep", "dataframes")

## Output ===========
figures_dir <- file.path("5_data_prep", "figures")
rdata_dir <- file.path("5_data_prep", "rdata")

# Load data -----------------------------------------------
counts <- read.csv(file.path(dataframes_dir, "raw_counts.csv"), row.names = 1)
coldata <- read.csv(file.path(dataframes_dir, "coldata.csv"), row.names = 1)
id2name <- read.csv(file.path(dataframes_dir, "id2name.csv"), row.names = 1)

# Variance stabilizing transformation (VST) -----------------------------------------------
dds <- DESeqDataSetFromMatrix(round(counts), coldata, design = ~ time)
dds <- estimateSizeFactors(dds)
vst <- varianceStabilizingTransformation(dds, blind = TRUE)

# Clustering -----------------------------------------------
pca_data <- plotPCA(vst, intgroup = c("Run", "time"), returnData = TRUE)
percent_var <- round(100 * attr(pca_data, "percentVar"))

# Colour points by the sample, indicated by `Run`
pca_plot_run <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Run)) +
  geom_point(size = 3) +
  xlab(paste0("PC1: ", percent_var[1], "% variance")) +
  ylab(paste0("PC2: ", percent_var[2], "% variance")) +
  theme_bw()
pca_plot_run

# Colour points by the experimental condition, indicated by `time`
pca_plot_time <- ggplot(pca_data, aes(x = PC1, y = PC2, color = time)) +
  geom_point(size = 3) +
  xlab(paste0("PC1: ", percent_var[1], "% variance")) +
  ylab(paste0("PC2: ", percent_var[2], "% variance")) +
  theme_bw()
pca_plot_time

# Saving
ggsave(
  plot = pca_plot_run, path = figures_dir,
  filename = "pca_plot_run.pdf",
  width = 120, height = 90, units = "mm"
)
ggsave(
  plot = pca_plot_time, path = figures_dir,
  filename = "pca_plot_time.pdf",
  width = 120, height = 90, units = "mm"
)

# Remove outliers -----------------------------------------------
counts_clean <- counts
coldata_clean <- coldata

# Save -----------------------------------------------
write.csv(counts_clean, file.path(dataframes_dir, "clean_counts.csv"))
write.csv(coldata_clean, file.path(dataframes_dir, "clean_coldata.csv"))

# Normalization -----------------------------------------------
dge_list <- DGEList(counts_clean)
calc <- calcNormFactors(dge_list, method = "TMM")
counts_norm <- cpm(calc, normalized.lib.sizes = TRUE)

# Filtering -----------------------------------------------
# The resulting mads are saved as a one-column dataframe.
mads <- data.frame(mad = apply(X = counts_norm, MARGIN = 1, FUN = mad))
rownames(mads) <- rownames(counts_norm) # setting the rownames to the gene ids

# Inspect the resulting dataframe
head(mads)

# Thresholds
quantile(mads$mad, probs = seq(0, 0.9, 0.01)) # 0th to 90th percentiles

# Filtering
filt_threshold <- 0.0007602902
genes_to_keep <- rownames(mads)[mads$mad >= filt_threshold]
counts_filt <- counts_norm[genes_to_keep, ]

cat("Number of genes before filtering: ", nrow(counts_norm), "\n")
cat("Number of genes after filtering: ", nrow(counts_filt), "\n")

# Save -----------------------------------------------
write.csv(counts_filt, file.path(dataframes_dir, "filtered_counts.csv"))
write.csv(mads, file.path(dataframes_dir, "mads.csv"))
saveRDS(genes_to_keep, file.path(rdata_dir, "genes_to_keep.rds"))
