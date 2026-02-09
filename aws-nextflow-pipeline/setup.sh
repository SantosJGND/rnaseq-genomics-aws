#!/bin/bash

# AWS Nextflow Pipeline Setup Script

set -e

echo "=== AWS Nextflow Pipeline Setup ==="

# Parse arguments
LOCAL_SETUP=false
for arg in "$@"; do
    if [ "$arg" == "--local" ]; then
        LOCAL_SETUP=true
    fi
done

# Create necessary directories
mkdir -p data reference/hisat2_index results/{qc,trimmed,alignment,counts}

# Check if Nextflow is installed
if ! command -v nextflow &> /dev/null; then
    echo "Installing Nextflow..."
    curl -s https://get.nextflow.io | bash
    chmod +x nextflow
    sudo mv nextflow /usr/local/bin/
fi

if [ "$LOCAL_SETUP" = false ]; then
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install AWS CLI first."
        exit 1
    fi

    # Verify AWS credentials
    echo "Verifying AWS credentials..."
    aws sts get-caller-identity || {
        echo "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    }
else
    echo "Local setup selected. Skipping AWS checks."
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Place reference genome in reference/genome.fa"
echo "2. Place annotation file in reference/annotation.gtf"
echo "3. Place FASTQ files in data/"
echo "4. Configure params.json (already set with relative paths)"
if [ "$LOCAL_SETUP" = false ]; then
    echo "5. Run pipeline: ./run_pipeline.sh aws"
else
    echo "5. Run pipeline: ./run_pipeline.sh docker"
fi