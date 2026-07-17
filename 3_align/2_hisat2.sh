#!/bin/bash
#SBATCH --job-name=hisat2
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=24
#SBATCH --mem=10GB  # Job memory request
#SBATCH --time=0-0:10:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=hisat2.out
#SBATCH --error=hisat2.err
# Title: Hisat2 Alignment
# Author: Amanda Zacharias
# Date: 2026-06-26
# Email: 16amz1@queensu.ca
#-------------------------------------------------
# Notes -------------------------------------------
#
# Code -------------------------------------------
echo Job started at "$(date +%T)"
# Dependencies
module load StdEnv/2023 hisat2/2.2.1

# Variables
SAMDIR=./hisat2_sam
REPORTDIR=./hisat2_reports
mkdir -p "$SAMDIR" "$REPORTDIR"

# Alignment
hisat2 -p 24 \
    -x "./hisat2_index/GRCm39_index" \
    -1 "../2_trim/trimmed_reads/SRR11902288_1.trim.fastq.gz" \
    -2 "../2_trim/trimmed_reads/SRR11902288_2.trim.fastq.gz" \
    --dta \
    --time \
    --verbose \
    --summary-file "${REPORTDIR}/SRR11902288_summary.txt" \
    -S "${SAMDIR}/SRR11902288.sam"

echo Job ended at "$(date +%T)"