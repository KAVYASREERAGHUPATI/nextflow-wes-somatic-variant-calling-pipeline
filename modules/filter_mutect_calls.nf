// Step 10: Somatic Variant Filtering
// Applies GATK FilterMutectCalls to classify Mutect2 candidate somatic variants before PASS variant selection.

process FILTER_MUTECT_CALLS {

    publishDir "${baseDir}/results/filtered_vcf", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), path(vcf_gz), path(vcf_index), path(vcf_stats)
    tuple path(ref), path(ref_fai), path(ref_dict)

    output:
    tuple val(patient_id),
          path("${patient_id}_filtered.vcf.gz"),
          path("${patient_id}_filtered.vcf.gz.tbi")

    script:
    """
    gatk FilterMutectCalls \
        -R $ref \
        -V $vcf_gz \
        -O ${patient_id}_filtered.vcf.gz

    gatk IndexFeatureFile \
        -I ${patient_id}_filtered.vcf.gz
    """
}
