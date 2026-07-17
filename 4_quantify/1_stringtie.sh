#!/bin/bash
#SBATCH --job-name=stringtie
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=12
#SBATCH --mem=600MB  # Job memory request
#SBATCH --time=0-0:10:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=stringtie.out
#SBATCH --error=stringtie.err
# Title: Quantification
# Author: Amanda Zacharias
# Date: 2026-07-03
# Email: 16amz1@queensu.ca
#-------------------------------------------------
# Notes -------------------------------------------
#
# Code -------------------------------------------
echo Job started at "$(date +%T)"
# Options

# Dependencies
module load StdEnv/2023 stringtie/3.0.1
# Variables
GTFDIR=./gtfs
mkdir -p ${GTFDIR}/SRR11902288

# Body
stringtie -p 12 \
    -G ../0_data/gencode/gencode.vM32.primary_assembly.annotation.gtf \
    -e \
    -B \
    -o ${GTFDIR}/SRR11902288/SRR11902288.gtf \
    ../3_align/hisat2_bam/SRR11902288.sort.markdup.bam

echo Job ended at "$(date +%T)"