// Step 5: Read Alignment
// Aligns trimmed paired-end WES reads to the reference genome using BWA-MEM2 and generates coordinate-sorted BAM files.

process ALIGN_BWA {

    container "melanoma-wes:1.0"
    cpus 8

    input:
    tuple val(patient_id), val(sample_type), path(r1), path(r2)

    tuple path(ref),
          path(bwa_0123),
          path(bwa_amb),
          path(bwa_ann),
          path(bwa_bwt),
          path(bwa_pac)

    output:
    tuple val(patient_id), val(sample_type),
          path("${patient_id}_${sample_type}_sorted.bam")

    script:
    """
    bwa-mem2 mem -t ${task.cpus} \
    -R "@RG\\tID:${patient_id}_${sample_type}\\tSM:${patient_id}_${sample_type}\\tPL:ILLUMINA" \
    $ref $r1 $r2 | \
    samtools sort -@ ${task.cpus} -o ${patient_id}_${sample_type}_sorted.bam
    """
}

 //-R add a read group
    //@RG read group 
    // BWA-MEM2 aligns paired-end FASTQ reads to the reference genome and writes SAM-formatted alignments to stdout.
    // The pipe (|) sends these alignments directly to samtools sort, which sorts them by genomic coordinate and writes a sorted BAM file.
    // This avoids creating a large intermediate SAM file.
    // ID = read-group ID, SM = sample name, PL = sequencing platform.
    // The sample name stored in the BAM header helps downstream GATK/Mutect2 distinguish tumor and normal samples.
    // samtools index creates the .bam.bai index file for fast access to genomic regions.
