#!/bin/bash

# Setup for reference files and HISAT2 index preparation
# Usage: ./setup_reference.sh [profile]
# Default profile: aws
# Available profiles: aws, docker

# Show help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [profile]"
    echo "Setup reference files and build HISAT2 index"
    echo ""
    echo "Arguments:"
    echo "  profile    Nextflow execution profile (default: aws)"
    echo "             Available: aws, docker"
    echo ""
    echo "Examples:"
    echo "  $0           # Use default AWS profile"
    echo "  $0 docker    # Use local Docker execution"
    exit 0
fi

PROFILE=${1:-aws}

echo "=== Setting up reference files for Nextflow Pipeline ==="
echo "Profile: $PROFILE"

# Create reference directory structure
mkdir -p reference/hisat2_index

echo "✓ Created reference directory structure"

# Check if both reference files exist before building index
GENOME_EXISTS=false
ANNOTATION_EXISTS=false

# Check if user has provided reference files
if [ ! -f "reference/genome.fa" ]; then
    echo "⚠️  Please copy your reference genome to: reference/genome.fa"
    echo "   Example: cp /path/to/your/genome.fa reference/genome.fa"
else
    echo "✓ Reference genome found: reference/genome.fa"
    GENOME_EXISTS=true
fi

if [ ! -f "reference/annotation.gtf" ]; then
    echo "⚠️  Please copy your annotation file to: reference/annotation.gtf"
    echo "   Example: cp /path/to/your/annotation.gtf reference/annotation.gtf"
else
    echo "✓ Annotation file found: reference/annotation.gtf"
    ANNOTATION_EXISTS=true
fi


# Show current params.json configuration
if [ -f "params.json" ]; then
    echo ""
    echo "Current reference configuration in params.json:"
    if command -v jq &> /dev/null; then
        jq '.reference' params.json
        echo "HISAT2 index parameters:"
        jq '.hisat2_index' params.json
    else
        echo "  Reference genome: $(grep -A 1 '"reference"' params.json | grep '"genome"' | awk -F'"' '{print $4}')"
        echo "  Annotation file: $(grep -A 2 '"reference"' params.json | grep '"annotation"' | awk -F'"' '{print $4}')"
        echo "  Index directory: $(grep -A 3 '"reference"' params.json | grep '"index_dir"' | awk -F'"' '{print $4}')"
    fi
else
    echo ""
    echo "⚠️  params.json not found - please run from pipeline directory"
fi

echo ""

if [ -e "reference/hisat2_index/genome.1.ht2" ]; then
    echo "✓ HISAT2 index files found"
else
    echo "⚠️  HISAT2 index files not found - running index preparation"
    # Build HISAT2 index if reference files are available
    if [ "$GENOME_EXISTS" = true ] && [ "$ANNOTATION_EXISTS" = true ]; then
        echo "=== Building HISAT2 Index ==="
        echo "Running HISAT2 index preparation with profile: $PROFILE"
        
        # Check if nextflow is available
        if command -v nextflow &> /dev/null; then
            # Run the index preparation workflow
            nextflow run prepare.nf -profile $PROFILE -params-file params.json
            
            if [ $? -eq 0 ]; then
                echo "✓ HISAT2 index preparation completed successfully"
                echo "✓ Index files available in: reference/hisat2_index/"
            else
                echo "❌ HISAT2 index preparation failed"
                echo "Check the Nextflow logs above for details"
                exit 1
            fi
        else
            echo "❌ Nextflow not found in PATH"
            echo "Please install Nextflow or add it to your PATH"
            exit 1
        fi
    elif [ "$GENOME_EXISTS" = false ] || [ "$ANNOTATION_EXISTS" = false ]; then
        echo "⚠️  Cannot build HISAT2 index - missing reference files"
        if [ "$GENOME_EXISTS" = false ]; then
            echo "   - Please copy your reference genome to: reference/genome.fa"
        fi
        if [ "$ANNOTATION_EXISTS" = false ]; then
            echo "   - Please copy your annotation file to: reference/annotation.gtf"
        fi
        echo ""
        echo "Once reference files are in place, run: ./setup_reference.sh $PROFILE"
    fi
fi

echo ""
echo "=== Setup Complete ==="
if [ "$GENOME_EXISTS" = true ] && [ "$ANNOTATION_EXISTS" = true ]; then
    echo "✓ Reference files configured"
    echo "✓ HISAT2 index prepared"
    echo "✓ Ready to run main pipeline: ./run_pipeline.sh $PROFILE"
else
    echo "✓ Directory structure created"
    echo "⚠️  Add reference files and run: ./setup_reference.sh $PROFILE"
fi