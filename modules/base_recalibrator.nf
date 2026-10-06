// Step 7: Base Quality Score Recalibration - Model Building
// Uses known variant sites to learn systematic sequencing errors and generates a recalibration table for each BAM file.

process BASERECALIBRATOR {

    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), val(sample_type), path(marked_bam), path(bai)

    tuple path(ref), path(ref_fai), path(ref_dict)

    path(dbsnp)
    path(dbsnp_index)

    path(mills)
    path(mills_index)

    output:
    tuple val(patient_id), val(sample_type),
          path("${patient_id}_${sample_type}_recal_data.table")

    script:
    """
    gatk BaseRecalibrator \
        -I $marked_bam \
        -R $ref \
        --known-sites $dbsnp \
        --known-sites $mills \
        -O ${patient_id}_${sample_type}_recal_data.table
    """
}
