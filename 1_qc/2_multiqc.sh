#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=1
#SBATCH --mem=20MB  # Job memory request
#SBATCH --time=0-0:10:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=multiqc.out
#SBATCH --error=multiqc.err
# Title: MultiQC Report
# Author: Amanda Zacharias
# Date: 2026-06-24
# Email: 16amz1@queensu.ca
#-------------------------------------------------
# Notes -------------------------------------------
#
# Code -------------------------------------------
echo Job started at "$(date +%T)"
# Options

# Dependencies
module load StdEnv/2020 python/3.9.6
# Installation beforehand ( ~3 minutes):
# mkdir env # env is created in the project folder, not the 1_qc folder
# python3 -m venv env/multiqc_env   
# source env/multiqc_env/bin/activate
# pip install "multiqc==1.14"   # pin to last version before polars dependency
source ../env/multiqc_env/bin/activate
multiqc --version

# Variables

# Body
multiqc \
    --outdir multiqc_out \
    --cl-config "fastqc_config: { fastqc_theoretical_gc: mm10_txome }" \
    fastqc_out
deactivate

echo Job ended at "$(date +%T)"