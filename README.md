# RNA-seq Tutorial

This repository contains a complete, beginner-friendly RNA-seq workflow from raw FASTQ files to:

- gene-level count matrices,
- differential expression analysis (DEA), and
- enrichment analysis.

The workflow is organized as numbered stages so you can run each step independently and inspect outputs before continuing.

By Amanda Zacharias (16amz1@queensu.ca)

Last updated July 2026

## Dataset Context

- Organism: mouse (mm10/GRCm39)
- Example sample in alignment workflow: SRR11902288
- Multi-sample count matrix for analysis steps is provided in `0_data`.

Associated study:

- GSE151567: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE151567
- Zacharias et al., Commun Biol (2025): https://doi.org/10.1038/s42003-025-08371-7

## Repository Layout

```text
0_data/           input data (raw reads, reference genome, annotation, count metadata)
1_qc/             FastQC + MultiQC
2_trim/           fastp trimming
3_align/          HISAT2 indexing/alignment + SAM/BAM processing with samtools
4_quantify/       StringTie quantification + tximport count aggregation
5_data_prep/      QC-driven prep (PCA, normalization, filtering)
6_dea/            differential expression (edgeR)
7_enrichment/     functional enrichment (gprofiler2)
tutorial_p1.Rmd   tutorial narrative for raw reads -> counts
tutorial_p2.Rmd   tutorial narrative for counts -> biological interpretation
```

## Prerequisites

This project is designed for an HPC environment with SLURM.

### System tools (via module load)

- fastqc 0.12.1
- python 3.9.6 (for MultiQC virtual environment)
- fastp 1.0.1
- hisat2 2.2.1
- samtools 1.18
- stringtie 3.0.1

### R environment

Tested scripts use R 4.5.0 and these packages:

- dplyr
- tximport
- DESeq2
- ggplot2
- edgeR
- tibble
- gprofiler2

## Quick Start

From the repository root:

```bash
pwd
```

Expected output should be `rnaseq_tutorial`.

## Pipeline Execution Order

Run each stage from the repository root / project folder unless otherwise noted.

### 1) Quality control

```bash
cd 1_qc
sbatch 1_fastqc.sh
sbatch 2_multiqc.sh
cd ..
```

Key outputs:

- `1_qc/fastqc_out/*_fastqc.html`
- `1_qc/multiqc_out/multiqc_report.html`

### 2) Trimming

```bash
cd 2_trim
sbatch fastp.sh
cd ..
```

Key outputs:

- `2_trim/trimmed_reads/*.trim.fastq.gz`
- `2_trim/fastp_reports/*_fastp.html`

### 3) Alignment and BAM processing

```bash
cd 3_align
sbatch 1_index_hisat2.sh
sbatch 2_hisat2.sh
sbatch 3_samtools.sh
cd ..
```

Key outputs:

- `3_align/hisat2_index/GRCm39_index.*.ht2`
- `3_align/hisat2_sam/SRR11902288.sam`
- `3_align/hisat2_bam/SRR11902288.sort.markdup.bam`
- `3_align/hisat2_bam/SRR11902288.sort.markdup.bam.bai`

### 4) Quantification

```bash
cd 4_quantify
sbatch 1_stringtie.sh
cd ..
Rscript 4_quantify/2_combine.R
```

Key outputs:

- `4_quantify/gtfs/SRR11902288/SRR11902288.gtf`
- `4_quantify/counts/counts.csv`
- `4_quantify/counts/id2name.csv`

### 5) Data preparation

```bash
Rscript 5_data_prep/1_setup.R
Rscript 5_data_prep/2_data_prep.R
```

Key outputs:

- `5_data_prep/dataframes/clean_counts.csv`
- `5_data_prep/dataframes/clean_coldata.csv`
- `5_data_prep/dataframes/filtered_counts.csv`
- `5_data_prep/rdata/genes_to_keep.rds`

### 6) Differential expression analysis

```bash
Rscript 6_dea/1_dea.R
```

Key outputs:

- `6_dea/dataframes/all_results.csv`
- `6_dea/dataframes/sig_results.csv`
- `6_dea/figures/volcano_plot.png`
- `6_dea/rdata/dea.RData`

### 7) Enrichment analysis

```bash
Rscript 7_enrichment/1_enrichment.R
```

Key outputs:

- `7_enrichment/dataframes/gprofiler_results.csv`
- `7_enrichment/dataframes/gprofiler_link.txt`
- `7_enrichment/rdata/gost_res.rds`
- `7_enrichment/rdata/gprofiler.RData`

## Monitoring and Logs

Most shell stages are submitted with SLURM and write `.out` and `.err` logs.

Useful commands:

```bash
squeue -u "$USER"
```

Always inspect relevant `.out` and `.err` files before continuing to the next stage.

## Tutorial Documents

For guided explanations and teaching notes:

- `tutorial_p1.Rmd` / `tutorial_p1.html`
- `tutorial_p2.Rmd` / `tutorial_p2.html`

## Notes

- Current alignment scripts are configured for the sample `SRR11902288`.
- Several scripts use relative paths and assume they are run from the project root (for `Rscript`) or from the script's directory (for `sbatch` shell scripts).
- If you process more samples, update sample-specific filenames and verify sample order consistency between count matrix columns and metadata rows.
