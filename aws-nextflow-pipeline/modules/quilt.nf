/*
 * QUILT Integration - Package and share analysis results on QUILT platform
 * 
 * Integrates with QUILT for standardized data packaging and sharing of CRISPRi Perturb-seq
 * analysis results. Creates version-controlled data packages with comprehensive metadata.
 * 
 * Status: NOT INTEGRATED - add to main.nf after MultiQC completion
 * 
 * Input:
 * - path bam_dir: Aligned BAM files directory
 * - path counts_dir: Gene count matrices directory  
 * - path multiqc_report: MultiQC HTML report
 * - path multiqc_data: MultiQC raw data directory
 * 
 * Output:
 * - val "quilt_package_created": Status indicator
 * 
 * Parameters:
 * - params.run_id: Unique identifier for package versioning
 * - QUILT authentication: Environment variables required
 * 
 * Integration: QUILT_PACKAGE(bam_files_data, count_results, multiqc_report, multiqc_data)
 * Example: quilt_status = QUILT_PACKAGE(bam_files_data, count_results, multiqc_report, multiqc_data)
 * 
 * Note: Add include { QUILT_PACKAGE } from './modules/quilt' to main.nf
 */


process QUILT_PACKAGE {

    tag "quilt_package"

    input:
    path bam_dir
    path counts_dir
    path multiqc_report
    path multiqc_data

    output:
    val "quilt_package_created"

    script:
    """
    cat > metadata.yaml <<EOF
        run_id: ${params.run_id}
        organism: homo_sapiens
        genome_build: hg38
        assay: perturb_seq
        qc:
        tool: multiqc
        version: 1.19
    EOF

    quilt3 push \
    genexomics/perturbseq/${params.run_id} \
    bam=${bam_dir} \
    counts=${counts_dir} \
    qc_report=${multiqc_report} \
    qc_data=${multiqc_data} \
    metadata.yaml
  """
}
