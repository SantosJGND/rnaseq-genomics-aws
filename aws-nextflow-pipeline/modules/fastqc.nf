/*
 * FastQC - Quality assessment for raw paired-end sequencing reads
 * 
 * Performs comprehensive quality assessment using FastQC, generating HTML reports and ZIP
 * archives with detailed quality metrics including per-base quality, duplication levels,
 * adapter content, and GC distribution analysis.
 * 
 * Input:
 * - tuple val(sample_id), path(read1), path(read2): Paired-end FASTQ files
 * 
 * Output:
 * - val sample_id, emit: qc_sample_id: Sample identifier
 * - path "*_fastqc.html", emit: qc_html_files: FastQC HTML reports
 * - path "${sample_id}_R1_fastqc.zip", emit: qc_zip_r1: Read1 FastQC archive
 * - path "${sample_id}_R2_fastqc.zip", emit: qc_zip_r2: Read2 FastQC archive
 * 
 * Parameters:
 * - fastqc.threads: CPU threads (default: 2)
 * - fastqc.memory: Memory allocation (default: 4 GB)
 * 
 * Integration: HTML and ZIP files suitable for MultiQC integration
 * Example: (qc_sample_ids, qc_html_files, qc_zip_r1, qc_zip_r2) = fastqc(read_pairs)
 */

process fastqc {
    label 'qc'
    cpus params['fastqc.threads']
    memory params['fastqc.memory']

    publishDir "${params.results}/qc", mode: 'copy', pattern: "*_fastqc.*"

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    val sample_id, emit: qc_sample_id
    path "*_fastqc.html", emit: qc_html_files
    path "${sample_id}_R1_fastqc.zip", emit: qc_zip_r1
    path "${sample_id}_R2_fastqc.zip", emit: qc_zip_r2

    script:
    """
    fastqc -t ${task.cpus} -o . ${read1} ${read2}
    """
}

/*
 * FastQC ZIP Aggregation Module
 * 
 * Consolidates individual FastQC ZIP archives for paired-end reads into a single
 * compressed archive per sample. This process facilitates organized storage
 * and efficient transfer of FastQC results.
 * 
 * Inputs:
 * - val sample_id: Sample identifier for archive naming
 * - tuple path(qc1), path(qc2): Individual FastQC ZIP archives for read pairs
 * 
 * Outputs:
 * - path "${sample_id}_fastqc.zip": Consolidated FastQC archive containing both read pairs
 * 
 * Dependencies:
 * - zip utility: Archive creation and compression
 * - Nextflow v20.10+: Workflow management system
 * 
 * Archive Structure:
 * - Contains both R1 and R2 FastQC reports
 * - Maintains original FastQC directory structure
 * - Optimized for storage and transfer efficiency
 * 
 * Example Usage:
 * consolidated_zip = fastqc_files_zip(sample_id, (zip_r1, zip_r2))
 */
