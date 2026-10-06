// Step 9: Somatic Variant Calling
// Uses matched tumor-normal recalibrated BAM files with gnomAD and a Panel of Normals to identify candidate somatic variants.

process MUTECT2 {

    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id),
          val(tumor_type), path(tumor_bam), path(tumor_bai),
          val(normal_type), path(normal_bam), path(normal_bai)

    tuple path(ref), path(ref_fai), path(ref_dict)

    tuple path(gnomad), path(gnomad_tbi)

    tuple path(pon), path(pon_tbi)

    output:
    tuple val(patient_id),
          path("${patient_id}_unfiltered.vcf.gz"),
          path("${patient_id}_unfiltered.vcf.gz.tbi"),
          path("${patient_id}_unfiltered.vcf.gz.stats")

    script:
    """
    gatk Mutect2 \
        -R $ref \
        -I $tumor_bam \
        -I $normal_bam \
        -tumor ${patient_id}_tumor \
        -normal ${patient_id}_normal \
        --germline-resource $gnomad \
        --panel-of-normals $pon \
        -O ${patient_id}_unfiltered.vcf.gz

    gatk IndexFeatureFile \
        -I ${patient_id}_unfiltered.vcf.gz
    """
}

