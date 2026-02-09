/*
 * HISAT2 Index Building - Create genome indices for splice-aware alignment
 * 
 * Builds hierarchical FM-index structures from reference FASTA files for HISAT2 alignment.
 * Automatically detects large genomes and enables appropriate indexing mode.
 * 
 * Input:
 * - path genome_fasta: Reference genome FASTA file
 * - val index_dir: Directory for index storage
 * 
 * Output:
 * - path "${index_dir}/genome.*.ht2": Complete HISAT2 index files (genome.1.ht2 through genome.8.ht2)
 * - path "${index_dir}/index_build.log": Build execution log
 * 
 * Parameters:
 * - hisat2_index.threads: CPU threads (default: 4)
 * - hisat2_index.memory: Memory allocation (default: 16 GB)
 * - hisat2_index.large_index: Enable large genome mode (default: auto-detect)
 * 
 * Integration: Output indices compatible with hisat2.nf alignment module
 * Example: index_files = hisat2_index(genome_fasta_ch, index_dir_str)
 */

process hisat2_index {

    label 'index_building'
    cpus params['hisat2_index.threads'] ?: 4
    memory params['hisat2_index.memory'] ?: '16 GB'

    publishDir "${index_dir}", mode: 'copy', pattern: "*.ht2"
    publishDir "${index_dir}", mode: 'copy', pattern: "*.log"

    input:
    path genome_fasta
    val index_dir

    output:
    path "${index_dir}/genome.*.ht2"
    path "${index_dir}/index_build.log"

    script:
    """
    # Create index directory
    mkdir -p ${index_dir}

    # Check if index already exists
    if [ -e "${index_dir}/genome.1.ht2" ]; then
        echo "HISAT2 index already exists at ${index_dir}/genome.*.ht2"
        echo "Skipping index building - using existing files" > ${index_dir}/index_build.log
        ls -la ${index_dir}/genome.*.ht2 >> ${index_dir}/index_build.log 2>&1
    else
        echo "Building HISAT2 index from ${genome_fasta}" | tee ${index_dir}/index_build.log
        echo "Target directory: ${index_dir}" | tee -a ${index_dir}/index_build.log
        echo "Using threads: ${task.cpus}" | tee -a ${index_dir}/index_build.log
        echo "Memory allocated: ${task.memory}" | tee -a ${index_dir}/index_build.log
        echo "Started at: \$(date)" | tee -a ${index_dir}/index_build.log
        
        # Check genome size and determine if large index is needed
        GENOME_SIZE=\$(wc -c < ${genome_fasta})
        echo "Genome file size: \${GENOME_SIZE} bytes" | tee -a ${index_dir}/index_build.log
        
        # Build index with auto-detection of large genome mode
        if [ \${GENOME_SIZE} -gt 4000000000 ]; then
            echo "Large genome detected (>4GB), enabling large-index mode" | tee -a ${index_dir}/index_build.log
            LARGE_INDEX_FLAG="--large-index"
        else
            echo "Standard genome size, using normal index mode" | tee -a ${index_dir}/index_build.log
            LARGE_INDEX_FLAG=""
        fi
        
        # Build the index
        hisat2-build \\
            -p ${task.cpus} \\
            \${LARGE_INDEX_FLAG} \\
            ${genome_fasta} \\
            ${index_dir}/genome 2>&1 | tee -a ${index_dir}/index_build.log
        
        # Verify index creation
        if [ -e "${index_dir}/genome.1.ht2" ]; then
            echo "Index building completed successfully at: \$(date)" | tee -a ${index_dir}/index_build.log
            echo "Generated index files:" | tee -a ${index_dir}/index_build.log
            ls -la ${index_dir}/genome.*.ht2 | tee -a ${index_dir}/index_build.log
            
            # Calculate total index size
            TOTAL_SIZE=\$(du -sh ${index_dir}/genome.*.ht2 | awk '{sum += \$1} END {print sum}')
            echo "Total index size: \${TOTAL_SIZE}" | tee -a ${index_dir}/index_build.log
        else
            echo "ERROR: Index building failed - genome.1.ht2 not found" | tee -a ${index_dir}/index_build.log
            exit 1
        fi
    fi
    """
}