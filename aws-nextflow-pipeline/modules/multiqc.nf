/*
 * MultiQC - Aggregate QC reports from multiple tools into single HTML report
 * 
 * Generates comprehensive quality control reports by aggregating results from FastQC,
 * FastP, HISAT2, featureCounts and other tools into a single interactive HTML report.
 * Supports various input formats and provides dynamic visualization capabilities.
 * 
 * Input:
 * - path qc_files: Collection of QC output files from pipeline tools
 * 
 * Output:
 * - path "multiqc_report.html": Interactive HTML report with consolidated QC metrics
 * - path "multiqc_data": Directory containing raw data for report generation
 * 
 * Parameters:
 * - multiqc.threads: CPU threads (default: 2)
 * - multiqc.memory: Memory allocation (default: 4 GB)
 * 
 * Integration: Accepts QC files from FastQC, FastP, HISAT2, featureCounts
 * Example: multiqc(multiqc_results)
 */

process multiqc {

  tag "multiqc"

  publishDir "${params.results}/multiqc", mode: 'copy', pattern: "multiqc_report.html"

  input:
  path collected_qc_zip_r1
  path collected_qc_zip_r2
  path collected_fastp_json
  path collected_flagstat_files

  output:
  path "multiqc_report.html"
  path "multiqc_data"

  script:
  """
    mkdir -p qc_input
    mv ${collected_qc_zip_r1} qc_input/
    mv ${collected_qc_zip_r2} qc_input/
    mv ${collected_fastp_json} qc_input/
    mv ${collected_flagstat_files} qc_input/
    multiqc \
    --force \
    --outdir . \
    qc_input
  """
}
