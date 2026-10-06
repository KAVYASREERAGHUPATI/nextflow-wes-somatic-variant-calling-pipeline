// Step 8: Base Quality Score Recalibration - Application
// Applies the learned BQSR corrections to the marked BAM files and generates recalibrated BAM files for variant calling.

process APPLY_BQSR {

    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), val(sample_type),
          path(marked_bam), path(bai), path(recal_table)

    tuple path(ref), path(ref_fai), path(ref_dict)

    output:
    tuple val(patient_id), val(sample_type),
          path("${patient_id}_${sample_type}_recalibrated.bam"),
          path("${patient_id}_${sample_type}_recalibrated.bam.bai")

    script:
    """
    gatk ApplyBQSR \
        -I $marked_bam \
        -R $ref \
        --bqsr-recal-file $recal_table \
        -O ${patient_id}_${sample_type}_recalibrated.bam

    samtools index ${patient_id}_${sample_type}_recalibrated.bam
    """
}

// BaseRecalibrator learns systematic base-quality errors; ApplyBQSR applies those learned corrections to the marked_BAM.i
//BQSR improves the accuracy of the base-quality scores so downstream variant callers such as Mutect2 can better judge how trustworthy the sequencing evidence for a variant is.
