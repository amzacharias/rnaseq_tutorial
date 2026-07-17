#!/usr/bin/env Rscript
# -*-coding: utf-8 -*-
#-----------------------------------------------
# Title: Combine count info across samples
# Author: Amanda Zacharias
# Date: 2026-07-03
# Email: 16amz1@queensu.ca
# Notes -----------------------------------------------
# module load StdEnv/2023 r/4.5.0

# Options -----------------------------------------------

# Packages -----------------------------------------------
library(dplyr)
library(tximport)

# Pathways -----------------------------------------------
## Input ===========
files <- list.files(
  file.path("4_quantify", "gtfs"),
  full.names = TRUE, # return the entire path 
  recursive = TRUE,  # search within folders
  pattern = "t_data.ctab$" # find all files that end with "t_data.ctab"
)
# convert the vector of paths into a named vector, where the names are the sample names
names(files) <- basename(dirname(files))

## Output ===========
counts_dir <- file.path("4_quantify", "counts")
dir.create(counts_dir)

# Load data -----------------------------------------------
# Read in one of the files
tmp <- read.delim(files[1])

# Extract the transcript id and gene name information
tx2gene <- tmp[, c("t_name", "gene_name")]

# Id2name
id2name <- tmp[, c("gene_id", "gene_name")] |>
  subset(! gene_name == ".") |>
  distinct()

# Tximport
txi <- tximport(files, type = "stringtie", tx2gene = tx2gene, readLength = 50)
gene_counts <- txi$counts

# Again removing genes lacking a known gene name for simplicity
gene_counts <- gene_counts[! rownames(gene_counts) %in% ".", drop = FALSE]

# Save -----------------------------------------------
write.csv(gene_counts, file = file.path("4_quantify", "counts", "counts.csv"))
write.csv(id2name, file = file.path("4_quantify", "counts", "id2name.csv"))
