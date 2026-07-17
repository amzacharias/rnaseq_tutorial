#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=2
#SBATCH --mem=7GB  # Job memory request
#SBATCH --time=0-0:10:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=fastp.out
#SBATCH --error=fastp.err
# Title: Fastp Trimming of sequencing reads
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
module load StdEnv/2023 fastp/1.0.1

# Variables
READSPATH=$(pwd)/../0_data/raw_reads
TRIMREADSDIR=$(pwd)/trimmed_reads
REPORTSDIR=$(pwd)/fastp_reports
mkdir -p "$TRIMREADSDIR" "$REPORTSDIR"
MAX_JOBS=2

# Function
run_fastp() {
    file="$1"
    base=$(basename "$file" _1.fastq.gz)
    echo "Running Fastp on $file"
    fastp \
        -q 20 \
        -l 30 \
        -i "$file" \
        -I "${READSPATH}/${base}_2.fastq.gz" \
        -o "${TRIMREADSDIR}/${base}_1.trim.fastq.gz" \
        -O "${TRIMREADSDIR}/${base}_2.trim.fastq.gz" \
        -h "${REPORTSDIR}/${base}_fastp.html" \
        -j "${REPORTSDIR}/${base}_fastp.json"
}

# Execute
export -f run_fastp
export READSPATH TRIMREADSDIR REPORTSDIR

find "$READSPATH" -name "*_1.fastq.gz" | \
    parallel --jobs "$MAX_JOBS" run_fastp {}

echo Job ended at "$(date +%T)"