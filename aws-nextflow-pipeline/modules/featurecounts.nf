/*
 * featureCounts - Gene-level expression quantification from aligned RNA-Seq reads
 * 
 * Performs gene-level expression quantification using featureCounts from Subread package.
 * Supports strand-specific counting, multi-mapping handling, and generates comprehensive
 * counting statistics suitable for downstream differential expression analysis.
 * 
 * Input:
 * - tuple val(sample_id), path(bam_file): Sorted BAM file with sample identifier
 * - path annotation_file: GTF annotation file for feature definition
 * 
 * Output:
 * - path "${sample_id}_counts.txt", emit: count_results: Gene count matrix
 * - path "${sample_id}_featureCounts.log": Counting execution log
 * 
 * Parameters:
 * - featurecounts.threads: CPU threads (default: 4)
 * - featurecounts.memory: Memory allocation (default: 8 GB)
 * - featurecounts.feature_type: Feature type to count (default: "exon")
 * - featurecounts.attribute_type: Gene identification attribute (default: "gene_id")
 * - featurecounts.strand_specific: Strand protocol (default: 0 for unstranded)
 * - featurecounts.min_overlap: Minimum overlap for assignment (default: 1)
 * 
 * Integration: Output compatible with DESeq2, edgeR, limma-voom
 * Example: count_results = featurecounts(bam_files_data, genome_annotation_ch)
 */

process featurecounts {
    label 'counting'
    cpus params['featurecounts.threads']
    memory params['featurecounts.memory']

    publishDir "${params.results}/counts", mode: 'copy', pattern: "*_counts.txt"

    input:
    tuple val(sample_id), path(bam_file)
    path reference_gtf

    output:
    tuple val(sample_id), path("${sample_id}_counts.txt"), emit: count_files
    path "featurecounts_summary.txt"

    script:
    """
    featureCounts \\
        -T ${task.cpus} \\
        -a ${reference_gtf} \\
        -o ${sample_id}_counts.txt \\
        -t ${params['featurecounts.feature_type']} \\
        -g ${params['featurecounts.attribute_type']} \\
        -s ${params['featurecounts.strand_specific']} \\
        --minOverlap ${params['featurecounts.min_overlap']} \\
        ${bam_file} \\
        2> featurecounts_summary.txt
    
    # Clean up the output file (remove header lines)
    tail -n +3 ${sample_id}_counts.txt > ${sample_id}_counts_clean.txt
    mv ${sample_id}_counts_clean.txt ${sample_id}_counts.txt
    """
}
