#!/usr/bin/env Rscript
# -*-coding: utf-8 -*-
#-----------------------------------------------
# Title: Data preparation
# Author: Amanda Zacharias
# Date: 2026-07-03
# Email: 16amz1@queensu.ca
# Notes -----------------------------------------------
# module load StdEnv/2023 r/4.5.0

# Packages -----------------------------------------------
# BiocManager::install(c("edgeR", "dplyr", "tibble", "ggplot2", "DESeq2"))

# Pathways -----------------------------------------------
## Input ===========
data_dir <- "0_data"
counts_path <- file.path(data_dir, "counts.csv")
coldata_path <- file.path(data_dir, "coldata.csv")
id2name_path <- file.path(data_dir, "id2name.csv")

## Output ===========
prep_dir <- "5_data_prep"
dataframes_dir <- file.path(prep_dir, "dataframes")
figures_dir <- file.path(prep_dir, "figures")
rdata_dir <- file.path(prep_dir, "rdata")

# Create the output directories using R instead of unix.
# dir.create(dataframes_dir)
# dir.create(figures_dir)
# dir.create(rdata_dir)

# Load data -----------------------------------------------
counts <- read.csv(counts_path, row.names = 1)
coldata <- read.csv(coldata_path, row.names = 1)
id2name <- read.csv(id2name_path, row.names = 1)

# Inspect data -----------------------------------------------
## Coldata ===========
nrow(coldata) # number of samples
ncol(coldata) # number of columns in the coldata dataframe
head(coldata) # first 10 rows of the coldata dataframe
summary(coldata) # summary statistics of the coldata dataframe

## Count matrix ===========
nrow(counts) # number of samples
ncol(counts) # number of columns in the count matrix
head(counts) # first 10 rows of the count matrix

## Id2name ===========
nrow(id2name) # number of genes
head(id2name) # first 10 rows of the id2name dataframe

# Do counts and id2name match? -----------------------------------------------
all(rownames(counts) %in% id2name$gene_name) # should return TRUE
all(id2name$gene_name %in% rownames(counts)) # should return TRUE

# Order of samples -----------------------------------------------
all(coldata$Run == colnames(counts)) # should return TRUE

# Save -----------------------------------------------
write.csv(counts, file.path(dataframes_dir, "raw_counts.csv"))
write.csv(id2name, file.path(dataframes_dir, "id2name.csv"))
write.csv(coldata, file.path(dataframes_dir, "coldata.csv"))
