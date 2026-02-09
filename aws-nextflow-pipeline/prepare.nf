#!/usr/bin/env nextflow

/*
 * HISAT2 Index Preparation Workflow
 * 
 * Dedicated workflow for preparing HISAT2 genome indices from reference files.
 * This workflow should be run once to prepare reference indices before running
 * the main RNA-Seq alignment pipeline.
 * 
 * Usage:
 * nextflow run prepare.nf -profile [aws|docker|local|conda]
 * 
 * Requirements:
 * - Reference genome FASTA file specified in params.json
 * - Sufficient disk space for index files (typically 4-8x genome size)
 * - Adequate memory for index building (16+ GB recommended for large genomes)
 * 
 * Outputs:
 * - Complete HISAT2 index files in reference/hisat2_index/
 * - Index building log with detailed statistics
 * 
 * Profile Options:
 * - aws: Run on AWS Batch (default)
 * - docker: Run locally with Docker
 * - local: Run locally without containers
 * - conda: Run locally with Conda environments
 */

params.json = "params.json"

// Load parameters from JSON file
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

    log.info("=== HISAT2 Index Preparation Workflow ===")
    log.info("Loaded parameters from ${params.json}")
    log.info("Reference genome: ${params['reference.genome']}")
    log.info("Index directory: ${params['reference.index_dir']}")
    log.info("Execution profile: ${workflow.profile}")

    // Input channels for reference preparation
    genome_fasta_ch = Channel.value(file(params['reference.genome']))
    index_dir_ch = Channel.value(params['reference.index_dir'].toString())

    // Build HISAT2 index
    hisat2_index(genome_fasta_ch, index_dir_ch)

    log.info("HISAT2 index preparation complete!")
    log.info("Index files available in: ${params['reference.index_dir']}")
    log.info("Ready to run main pipeline: nextflow run main.nf")
}

// Include the index building module
include { hisat2_index } from './modules/hisat2_index'