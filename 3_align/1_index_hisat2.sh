#!/bin/bash
#SBATCH --job-name=index_hisat
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=16amz1@queensu.ca
#SBATCH --cpus-per-task=10
#SBATCH --mem=150GB  # Job memory request
#SBATCH --time=0-1:00:00  # Day-Hours-Minutes-Seconds
#SBATCH --output=index_hisat.out
#SBATCH --error=index_hisat.err
# Title: Index the reference genome for Hisat2
# Author: Amanda Zacharias
# Date: 2026-06-26
# Email: 16amz1@queensu.ca
#-------------------------------------------------
# Notes -------------------------------------------
#
# Code -------------------------------------------
echo Job started at "$(date +%T)"
# Options

# Dependencies
module load StdEnv/2023 hisat2/2.2.1
# Variables
GENOMEDIR=../0_data/gencode
INDEXDIR=./hisat2_index
mkdir -p ${INDEXDIR}

# Body
echo "Extracting splice sites and exons from GTF file..."
hisat2_extract_splice_sites.py ${GENOMEDIR}/gencode.vM32.primary_assembly.annotation.gtf > ${INDEXDIR}/GRCm39.ss
hisat2_extract_exons.py ${GENOMEDIR}/gencode.vM32.primary_assembly.annotation.gtf > ${INDEXDIR}/GRCm39.exon

echo "Building Hisat2 index..."
hisat2-build -p 20 \
    -f ${GENOMEDIR}/GRCm39.primary_assembly.genome.fa \
    --ss ${INDEXDIR}/GRCm39.ss \
    --exon ${INDEXDIR}/GRCm39.exon \
    ${INDEXDIR}/GRCm39_index

echo Job ended at "$(date +%T)"