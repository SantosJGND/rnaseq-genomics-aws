# AWS Nextflow RNA-Seq Processing Pipeline

## Overview

A Nextflow pipeline for RNA-Seq data analysis. This pipeline implements data processing, quality control, and result generation with support for execution on AWS Batch.

## System Requirements

### Minimum Specifications

- **CPU**: 4 cores
- **Memory**: 8GB RAM
- **Storage**: 50GB available space
- **Software**: Nextflow 20.10+, Docker 20.10+ or Conda 4.8+

## Pipeline Architecture

### Phase 1: Quality Control & Preprocessing

- **FastQC**: Comprehensive quality assessment of raw sequencing reads
- **Fastp**: Adapter detection, quality trimming, and filtering
- **Output**: Cleaned reads ready for alignment, QC reports

### Phase 2: Alignment & Quantification

- **HISAT2**: Splice-aware alignment to reference genome
- **featureCounts**: Gene-level expression quantification
- **Output**: Sorted BAM files, gene count matrices

### Phase 3: Reporting & Packaging

- **MultiQC**: Consolidated quality control reporting
- **QUILT**: Data packaging for sharing (optional, not integrated)
- **Output**: Comprehensive analysis reports

## Quick Start

### 1. Local Environment Setup

```bash
# Clone and setup
git clone <repository-url>
cd transfer_process/aws-nextflow-pipeline
./setup.sh [--local|--aws]
```

### 2. Local Reference File Configuration

```bash
# Reference genome (FASTA format)
cp your_genome.fa reference/genome.fa

# Gene annotation (GTF format)
cp your_annotation.gtf reference/annotation.gtf

# Build HISAT2 index (if not pre-built)
./setup_reference.sh [aws|docker] # deploys nextflow process.
```

### 3. Data Input

```bash
# Paired-end FASTQ files
cp sample_R1.fastq.gz data/
cp sample_R2.fastq.gz data/

# for the purpose of local testing:
cp -r ../data/test_data/* data/
```

### 4. Pipeline Execution

```bash
# Local execution with Docker
./run_pipeline.sh docker

# AWS Batch execution.
./run_pipeline.sh aws

```

### AWS Batch deployment on EC2

```bash
# Clone and setup
git clone <repository-url>
cd transfer_process/aws-nextflow-pipeline
./run_pipeline.sh aws
```

## Configuration Management

### Reference Files Configuration

Reference files are configured centrally in `params.json` under the `reference` section:

```json
"reference": {
    "genome": "reference/genome.fa",
    "annotation": "reference/annotation.gtf",
    "index_dir": "reference/hisat2_index"
}
```

### Pipeline Parameters

All tool parameters are defined in `params.json` with production-grade defaults:

```json
"fastqc": {
    "threads": 2,
    "memory": "4 GB"
},
"fastp": {
    "threads": 4,
    "memory": "8 GB",
    "cut_mean_quality": 20,
    "length_required": 35
},
"hisat2": {
    "threads": 3,
    "memory": "8 GB",
    "rna_strandness": "FR"
},
"featurecounts": {
    "threads": 4,
    "memory": "8 GB",
    "feature_type": "exon"
}
```

### Parameter Override

Command-line parameter override:

```bash
nextflow run main.nf -profile docker \
    --fastqc.threads 4 \
    --hisat2.memory "16 GB" \
    --fastp.cut_mean_quality 25
```

Permanent configuration changes should be made directly in `params.json`.

### AWS Configuration

AWS-specific settings are managed in `nextflow.config`:

- **Region**: AWS deployment region
- **Batch Queue**: Compute environment configuration

### Software Dependencies

- **Nextflow**: 24.10.2.5932 (workflow management)
- **Docker**: 29.1.3 (containerization)
- **AWS CLI**: 2.0+ (cloud interface - only for AWS deployment)
- **jq**: 1.6+ (JSON processing)

## Output Specifications

### Directory Structure

```
results/
├── qc/                   # Quality control reports
│   ├── fastqc/         # FastQC HTML reports
│   └── fastp/          # FastP HTML and JSON reports
├── trimmed/              # Processed sequencing reads
├── alignment/            # BAM files and alignment metrics
├── counts/              # Gene expression matrices
└── multiqc/             # Consolidated QC reports
```

### File Formats

- **FASTQ**: Input sequencing reads (gzipped)
- **BAM**: Aligned sequencing data (sorted, indexed)
- **GTF**: Gene annotation format
- **TSV/CSV**: Count matrices and metadata
- **HTML**: Quality control reports
- **JSON**: Machine-readable QC metrics

## Troubleshooting

### Common Issues

**Memory Errors**:

- Increase memory allocation in `params.json`
- Use AWS Batch with high-memory instances
- Reduce thread count to lower memory usage

**Index Missing**:

- Run `./setup_reference.sh` to build indices
- Verify reference file paths in configuration
- Check file permissions and accessibility

**AWS Batch Failures**:

- Verify IAM role permissions
- Check VPC and subnet configuration
- Ensure sufficient quota for compute resources

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
nextflow run main.nf -profile docker -debug
```
