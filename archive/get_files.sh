#!/bin/bash
#SBATCH --job-name=get_files
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=1
#SBATCH --mem=20MB  # Job memory request
#SBATCH --time=0-1:00:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=get_files.out
#SBATCH --error=get_files.err
# Title: Get tutorial files
# Author: Amanda Zacharias
# Date: 2026-06-30
# Email: 16amz1@queensu.ca
#-------------------------------------------------
# Notes -------------------------------------------
#
# Code -------------------------------------------
echo Job started at "$(date +%T)"
# Options

# Dependencies
module load StdEnv/2023
# Variables

# Body
cp ~/rnaseq_assignment/0_data/tut_reads/* ./raw_reads/

echo Job ended at "$(date +%T)"