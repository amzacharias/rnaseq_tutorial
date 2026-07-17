#!/bin/bash
#SBATCH --job-name=run_fastqc
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=2
#SBATCH --mem=1GB  # Job memory request
#SBATCH --time=0-0:10:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=run_fastqc.out
#SBATCH --error=run_fastqc.err
# Title: FastQC analysis of sequencing reads
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
module load StdEnv/2023 fastqc/0.12.1

# Variables
READSPATH=$(pwd)/../0_data/raw_reads
OUTDIR=$(pwd)/fastqc_out
mkdir -p "$OUTDIR"
MAX_JOBS=2

# Function
run_fastqc() {
    file="$1"
    echo "Running FastQC on $file"
    fastqc -o "$OUTDIR" "$file"
}

# Execute
export -f run_fastqc
export OUTDIR

find "$READSPATH" -name "*.fastq.gz" | \
    parallel --jobs "$MAX_JOBS" run_fastqc {}

echo Job ended at "$(date +%T)"