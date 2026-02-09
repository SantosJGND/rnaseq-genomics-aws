/*
 * STAR - Splice-aware RNA-Seq read alignment to reference genome
 * 
 * Performs alignment of paired-end sequencing reads using STAR aligner with
 * automatic index generation if not present. Outputs sorted BAM files
 * and alignment logs for quality assessment.
 * 
 * Input:
 * - tuple val(sample_id), path(read1), path(read2): Paired-end FASTQ files
 * - path genome_fasta: Reference genome FASTA
 * - path genome_gtf: Gene annotation GTF file
 * - path index_dir: Directory for STAR index storage
 * 
 * Output:
 * - tuple val(sample_id), path("${sample_id}.bam"), emit: bam_files: Sorted BAM
 * - path "${sample_id}_STAR.log": STAR alignment log
 * - path "${sample_id}_flagstat.txt": Alignment statistics
 * 
 * Parameters:
 * - star.threads: CPU threads for alignment
 * - star.memory: Memory allocation
 * - star.sjdb_overhang_min: sjdbOverhang parameter
 * - star.twopass_mode: Two-pass alignment mode
 * - star.align_sj_overhang_min: Minimum splice junction overhang
 * - star.align_sjdb_overhang_min: sjdbOverhang for alignment
 * - star.out_filter_mismatch_nover_lmax: Mismatch filter
 * 
 * Integration: Sorted BAM outputs suitable for downstream counting
 * Example: star(read_pairs, genome_fasta_ch, genome_gtf_ch, index_dir_ch)
 * Note: Not currently used in main workflow - HISAT2 is preferred
 */

process star {
    label 'alignment'
    cpus params['star.threads']
    memory params['star.memory']
    
    publishDir "${params.results}/alignment", mode: 'copy', pattern: "*.bam*"
    publishDir "${params.results}/alignment", mode: 'copy', pattern: "*_flagstat.txt"

    input:
    tuple val(sample_id), path(read1), path(read2)
    path genome_fasta
    path genome_gtf
    path index_dir

    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam_files
    path "${sample_id}_STAR.log"
    path "${sample_id}_flagstat.txt"

    script:
    """

    # Build index if not exists

    mkdir -p ${index_dir}
    if [ -z "`ls -A ${index_dir}`" ]; then

        STAR \\
            --runThreadN ${task.cpus} \\
            --
            --runMode genomeGenerate \\
            --genomeDir ${index_dir} \\
            --genomeFastaFiles ${genome_fasta} \\
            --sjdbGTFfile ${genome_gtf} \\
            -sjdbOverhang ${params['star.sjdb_overhang_min']}
    fi

    # Align reads
    STAR \\
        --runThreadN ${task.cpus} \\
        --genomeDir ${index_dir} \\
        --readFilesIn ${read1} ${read2} \\
        --readFilesCommand zcat \\
        --outFileNamePrefix ${sample_id}_ \\
        --outSAMtype BAM SortedByCoordinate \\
        --outStd Log \\
        --outSAMattrRGline ID:${params['star.twopass_mode']} SM:${params['star.sj_overhang_min']} LB:${params['star.sjdb_overhang_min']} PL:ILLUMINA \\
        --twopassMode ${params['star.twopass_mode']} \\
        --alignSJoverhangMin ${params['star.align_sj_overhang_min']} \\
        --alignSJDBoverhangMin ${params['star.align_sjdb_overhang_min']} \\
        --outFilterMismatchNoverLmax ${params['star.out_filter_mismatch_nover_lmax']} \\
        2> ${sample_id}_STAR.log
    
    # Rename and index BAM
    mv _Aligned.sortedByCoord.out.bam ${sample_id}.bam
    samtools index ${sample_id}.bam
    
    # Alignment verification
    samtools flagstat ${sample_id}.bam > ${sample_id}_flagstat.txt
    
    # Clean up
    rm -f _*
    """
}
