// Step 6: Duplicate Marking
// Identifies and marks duplicate reads in the aligned BAM files and generates duplication metrics before BQSR.

process MARK_DUPLICATES {

    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), val(sample_type), path(bam)

    output:
    tuple val(patient_id), val(sample_type),
          path("${patient_id}_${sample_type}_marked.bam"),
          path("${patient_id}_${sample_type}_marked.bam.bai"),
          path("${patient_id}_${sample_type}_dup_metrics.txt")

    script:
    """
    gatk MarkDuplicates \
        -I $bam \
        -O ${patient_id}_${sample_type}_marked.bam \
        -M ${patient_id}_${sample_type}_dup_metrics.txt

    samtools index ${patient_id}_${sample_type}_marked.bam
    """
}

//The metrics file is a report from GATK containing information about the duplicates it found—for example, how many reads were examined and how much duplication was detected.
