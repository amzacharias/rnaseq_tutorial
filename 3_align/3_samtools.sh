#!/bin/bash
#SBATCH --job-name=samtools
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=24
#SBATCH --mem=10GB  # Job memory request
#SBATCH --time=0-0:20:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=samtools.out
#SBATCH --error=samtools.err
# Title: Samtools sam to bam conversion and sorting
# Author: Amanda Zacharias
# Date: 2026-06-26
# Email: 16amz1@queensu.ca
#-------------------------------------------------
# Notes -------------------------------------------
#
# Code -------------------------------------------
echo Job started at "$(date +%T)"
# Dependencies
module load StdEnv/2023 samtools/1.18

# Variables
SAMDIR=./hisat2_sam
BAMDIR=./hisat2_bam
mkdir -p "$BAMDIR"

# Code
samtools view -@ 4 -b "${SAMDIR}/SRR11902288.sam" | \
    samtools collate -@ 4 -u -O - | \
    samtools fixmate -@ 2 -m -u - - | \
    samtools sort -@ 12 -l 0 - | \
    samtools markdup -@ 2 - "${BAMDIR}/SRR11902288.sort.markdup.bam"
samtools index "${BAMDIR}/SRR11902288.sort.markdup.bam"

echo Job ended at "$(date +%T)"