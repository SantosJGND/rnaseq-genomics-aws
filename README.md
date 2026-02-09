# CRISPRi Perturb-seq Analysis Pipeline

## Overview

A comprehensive bioinformatics pipeline for CRISPR interference (CRISPRi) Perturb-seq data analysis, combining RNA-Seq processing with CRISPR guide activity quantification.

## Architecture

The pipeline consists of three integrated components:

- **`data/`** - Minimal test data and scripts to complement.
- **`local-s3-transfer/`** - Automated S3 data synchronization service for secure data transfer, with local alternative for testing.
- **`aws-nextflow-pipeline/`** - Nextflow-based RNA-Seq processing pipeline with cloud-native execution support

### Prerequisites

- Nextflow 20.10+
- Docker 20.10+ or Conda 4.8+
- AWS CLI 2.0+ (for cloud execution)
- 8GB+ RAM, 4+ CPU cores (minimum)

## Component Documentation

- [Data Organization](data/README.md) - Data structure and metadata specifications
- [Transfer Service Documentation](local-s3-transfer/README.md) - Data synchronization setup and management
- [Pipeline Documentation](aws-nextflow-pipeline/README.md) - Detailed pipeline configuration and usage

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
