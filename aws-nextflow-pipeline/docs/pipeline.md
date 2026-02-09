# AWS Nextflow RNA-Seq Processing Pipeline

## Overview

2-step Nextflow pipeline for RNA-Seq data processing on AWS Batch:

1. **QC & Trimming**: FastQC quality assessment + Fastp adapter trimming
2. **Alignment & Counting**: HISAT2 alignment + featureCounts quantification

## Pipeline Structure

```
aws-nextflow-pipeline/
├── main.nf                 # Main pipeline script
├── nextflow.config         # AWS and process configuration
├── params.json            # Pipeline parameters
├── modules/               # Process modules
│   ├── fastqc.nf         # FastQC quality control
│   ├── fastp.nf          # Fastp trimming
│   ├── hisat2.nf         # HISAT2 alignment
│   ├── featurecounts.nf  # featureCounts quantification
│   ├── multiqc.nf        # MultiQC report generation
│   └── quilt.nf          # QUILT data packaging (not integrated)
├── utils/                 # Utility scripts and Dockerfiles
│   ├── hisat2/
│   └── star/
└── docs/                 # Documentation
```

## Prerequisites

- Nextflow installed
- AWS CLI configured
- AWS Batch queue configured
- Reference genome and annotation files

## Usage

### Local Execution (Conda)

```bash
nextflow run main.nf -profile conda
```

### AWS Batch Execution

```bash
nextflow run main.nf -profile aws
```

### Custom Parameters

```bash
nextflow run main.nf -profile aws --reads "path/to/reads/"
```

## Configuration

### params.json

Modify pipeline parameters:

- Input reads pattern
- Reference genome path
- Annotation file path
- Tool-specific parameters

### nextflow.config

AWS and execution settings:

- AWS region and Batch queue
- Process resource allocation
- Docker/Conda environments
- Error handling strategies

## Output Structure

```
results/
├── qc/                   # FastQC reports
├── trimmed/              # Fastp trimmed reads
├── alignment/            # BAM files and logs
└── counts/              # Gene count matrices
```

## Monitoring

Pipeline generates:

- `timeline.html` - Execution timeline
- `report.html` - Resource usage report
- `trace.txt` - Detailed execution trace
- `dag.svg` - Workflow DAG visualization
