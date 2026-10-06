// Step 3: Read Trimming
// Removes adapter sequences and low-quality bases from raw paired-end reads before alignment.

process TRIMMOMATIC {

    container "melanoma-wes:1.0"
    cpus 4

    input:
    tuple val(patient_id), val(sample_type), path(r1), path(r2)

    output:
    tuple val(patient_id), val(sample_type),
          path("${patient_id}_${sample_type}_R1_paired.fastq.gz"),
          path("${patient_id}_${sample_type}_R2_paired.fastq.gz"),
          emit: paired_reads

    script:
    """
    TrimmomaticPE \
        -threads ${task.cpus} \
        $r1 $r2 \
        ${patient_id}_${sample_type}_R1_paired.fastq.gz \
        ${patient_id}_${sample_type}_R1_unpaired.fastq.gz \
        ${patient_id}_${sample_type}_R2_paired.fastq.gz \
        ${patient_id}_${sample_type}_R2_unpaired.fastq.gz \
        ILLUMINACLIP:${params.trimmomatic_adapters}:2:30:10 \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36
    """
}
