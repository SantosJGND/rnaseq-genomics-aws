#!/usr/bin/env nextflow

/*
 * AWS Nextflow RNA-Seq Processing Pipeline
 * 2-step pipeline: QC/trimming -> alignment/counting
 */

params.json = "params.json"

// Load parameters from JSON file (must be done before workflow starts)
if (file(params.json).exists()) {
    def jsonText = file(params.json).text
    def config = new groovy.json.JsonSlurper().parseText(jsonText)
    
    // Flatten nested JSON to work with Nextflow parameter access
    config.each { k, v -> 
        if (v instanceof Map) {
            v.each { subKey, subValue -> params["${k}.${subKey}"] = subValue }
        } else {
            params[k] = v
        }
    }
}

// Workflow
workflow {

    log.info("=== AWS Nextflow RNA-Seq Pipeline ===")
    log.info("Loaded parameters from ${params.json}")
    log.info("Reads pattern: ${params.reads}")
    log.info("Results directory: ${params.results}")
    log.info("Reference genome: ${params['reference.genome']}")
    log.info("Annotation file: ${params['reference.annotation']}")
    log.info("HISAT2 index directory: ${params['reference.index_dir']}")
    log.info("Note: HISAT2 indices should be prepared with: nextflow run prepare.nf")

    // Create channels for reference files
    genome_annotation_ch = Channel.value(file(params['reference.annotation']))
    hisat2_index_ch = Channel.value(file(params['reference.index_dir']))

    // Channel setup
    Channel
        .fromFilePairs("${params.reads}/*_{R1,R2}.fastq.gz", checkIfExists: true)
        .ifEmpty { error "No read pairs found in ${params.reads}" }
        .set { read_pairs }


    read_pairs
        .map { sample_id, reads ->
            def (r1, r2) = reads
            tuple(sample_id, r1, r2)
        }
        .set { read_pairs }

    // Step 1: QC and Trimming
    (qc_sample_ids, qc_html_files, qc_zip_r1, qc_zip_r2) = fastqc(read_pairs)
    (trimmed_reads_data, fastp_html, fastp_json) = fastp(read_pairs)

    // Step 2: Alignment and Counting
    (bam_files_data, hisat2_logs, flagstat_files) = hisat2(trimmed_reads_data, hisat2_index_ch)
    count_results = featurecounts(bam_files_data, genome_annotation_ch)

    collected_qc_zip_r1 = qc_zip_r1.collect()
    collected_qc_zip_r2 = qc_zip_r2.collect()
    collected_fastp_json = fastp_json.collect()
    collected_flagstat_files = flagstat_files.collect()

    multiqc(collected_qc_zip_r1, collected_qc_zip_r2, collected_fastp_json, collected_flagstat_files)

    // Output channels are ready for processing
    log.info("Pipeline setup complete - ready to process data")
}




// Include modules
include { fastqc } from './modules/fastqc'
include { fastp } from './modules/fastp'
include { hisat2 } from './modules/hisat2'
include { featurecounts } from './modules/featurecounts'
include { multiqc } from './modules/multiqc'
