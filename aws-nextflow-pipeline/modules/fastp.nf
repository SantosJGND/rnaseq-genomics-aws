/*
 * Fastp - Quality control, adapter trimming and filtering for paired-end reads
 * 
 * Performs comprehensive preprocessing using FastP including automatic adapter detection,
 * quality-based trimming, length filtering, and generates detailed QC reports.
 * 
 * Input:
 * - tuple val(sample_id), path(read1), path(read2): Paired-end FASTQ files
 * 
 * Output:
 * - tuple val(sample_id), path("${sample_id}_trimmed_R1.fastq.gz"), path("${sample_id}_trimmed_R2.fastq.gz"), emit: trimmed_reads: Processed read pairs
 * - path "${sample_id}_fastp.html", emit: fastp_html: Interactive HTML QC report
 * - path "${sample_id}_fastp.json", emit: fastp_json: Machine-readable QC metrics
 * 
 * Parameters:
 * - fastp.threads: CPU threads (default: 4)
 * - fastp.memory: Memory allocation (default: 8 GB)
 * - fastp.cut_mean_quality: Quality threshold for trimming (default: 20)
 * - fastp.length_required: Minimum read length after filtering (default: 35)
 * - fastp.detect_adapter_for_pe: Automatic adapter detection (default: true)
 * 
 * Integration: HTML and JSON outputs integrate with MultiQC for QC visualization
 * Example: (trimmed_reads_data, fastp_html, fastp_json) = fastp(read_pairs)
 */

process fastp {
    label 'trimming'
    cpus params['fastp.threads']
    memory params['fastp.memory']

    publishDir "${params.results}/trimmed", mode: 'copy', pattern: "*_trimmed_*.fastq.gz"
    publishDir "${params.results}/qc", mode: 'copy', pattern: "*_fastp.*"

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed_R1.fastq.gz"), path("${sample_id}_trimmed_R2.fastq.gz"), emit: trimmed_reads
    path "${sample_id}_fastp.html", emit: fastp_html
    path "${sample_id}_fastp.json", emit: fastp_json

    script:
    """
    
    fastp \\
        -i ${read1} \\
        -I ${read2} \\
        -o ${sample_id}_trimmed_R1.fastq.gz \\
        -O ${sample_id}_trimmed_R2.fastq.gz \\
        -h ${sample_id}_fastp.html \\
        -j ${sample_id}_fastp.json \\
        -w ${task.cpus} \\
        --detect_adapter_for_pe \\
        --cut_mean_quality ${params['fastp.cut_mean_quality']} \\
        --length_required ${params['fastp.length_required']} \\
        --thread ${task.cpus}
    """
}
