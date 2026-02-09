# Research Data Storage

## Overview

This directory contains research data for Perturb-seq experiments and scripts to dl and edit filenames specific to project PRJNA912208.

## Directory Structure

```
data/
├── test/                  # Test datasets for pipeline validation
│   ├── SRR22741843_*.fastq.gz  # Sample sequencing data
│   └── SRR22741843_R*.fastq.gz # Alternative naming convention
├── convert_filenames.sh   # Utility script for file naming standardization
├── dl_bioproject.sh       # Data acquisition script
└── .gitkeep              # Directory preservation marker
```

## Data Specifications

### Sequencing Data

**File Format**: FASTQ (gzipped)
**Naming Convention**:

- Primary: `SampleID_{1,2}.fastq.gz`
- Alternative: `SampleID_{R1,R2}.fastq.gz`

## Data Provenance

### Source Information

- **BioProject**: [PRJNA912208](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA912208)
- **Primary Dataset**: [GSE220974](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE220974) (GEO)
- **Study Type**: CRISPRi Perturb-seq
- **Organism**: Homo sapiens
- **Cell Line**: Not specified in metadata
- **Platform**: Illumina sequencing

### Installation SRA toolkit

```bash
# Install SRA Toolkit
wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz

tar -vxzf sratoolkit.tar.gz

```

### Acquisition Methods

```bash
# Download all samples from BioProject PRJNA912208
nano dl_bioproject.sh # Edit the script with your SRA toolkit path
./dl_bioproject.sh

# Standardize file naming
./convert_filenames.sh test_data
```
