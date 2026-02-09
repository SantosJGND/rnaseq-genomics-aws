#!/bin/bash

# Example pipeline execution script

set -e

echo "=== Running AWS Nextflow Pipeline ==="

# Default profile
PROFILE=${1:-aws}
SKIP_JSON_VALIDATION=false

# Check for jq for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Warning: jq not found. Skipping JSON validation."
    echo "Install jq with: sudo apt-get install jq (Ubuntu) or brew install jq (macOS)"
    SKIP_JSON_VALIDATION=true
fi

# Check if reference files exist
if [ ! -f "reference/genome.fa" ]; then
    echo "Reference genome not found: reference/genome.fa"
    echo "Please place your reference genome in reference/genome.fa"
    exit 1
fi

if [ ! -f "reference/annotation.gtf" ]; then
    echo "Annotation file not found: reference/annotation.gtf"
    echo "Please place your annotation file in reference/annotation.gtf"
    exit 1
fi

# Check if params.json exists
if [ ! -f "params.json" ]; then
    echo "params.json not found"
    exit 1
fi

# Validate reference paths in params.json (if jq is available)
if [ "$SKIP_JSON_VALIDATION" != "true" ]; then

    GENOME_PATH=$(jq -r '.reference.genome' params.json 2>/dev/null)
    ANNOTATION_PATH=$(jq -r '.reference.annotation' params.json 2>/dev/null)


    if [ -z "$GENOME_PATH" ] || [ "$GENOME_PATH" = "null" ]; then
        echo "Could not read genome path from params.json - check file format"
        GENOME_PATH="reference/genome.fa"
    fi
    
    if [ -z "$ANNOTATION_PATH" ] || [ "$ANNOTATION_PATH" = "null" ]; then
        echo "Could not read annotation path from params.json - check file format"
        ANNOTATION_PATH="reference/annotation.gtf"
    fi
    
    if [ ! -f "$GENOME_PATH" ]; then
        echo "Reference genome not found at: $GENOME_PATH"
        echo "Check params.json reference.genome path"
        exit 1
    fi
    
    if [ ! -f "$ANNOTATION_PATH" ]; then
        echo "Annotation file not found at: $ANNOTATION_PATH"
        echo "Check params.json reference.annotation path"
        exit 1
    fi
    
    echo "Reference validation passed:"
    echo "  Genome: $GENOME_PATH"
    echo "  Annotation: $ANNOTATION_PATH"
else
    echo "Skipping reference file validation (jq not available)"
fi

# Check if data exists
if [ ! -d "data" ] || [ -z "$(ls -A data)" ]; then
    echo "No data found in data/ directory"
    exit 1
fi

echo "Profile: $PROFILE"
echo "Data directory: $(ls data | wc -l) files found"

# Run pipeline
nextflow run main.nf \
    -profile $PROFILE \
    -resume \
    -params-file params.json

echo "Pipeline completed successfully!"
echo "Check results/ directory for outputs."