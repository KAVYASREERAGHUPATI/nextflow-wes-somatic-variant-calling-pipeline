// Step 11: PASS Variant Selection
// Retains variants labeled PASS after Mutect2 filtering for downstream annotation.

process SELECT_PASS_VARIANTS {

    publishDir "${baseDir}/results/pass_vcf", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), path(filtered_vcf), path(filtered_vcf_index)

    output:
    tuple val(patient_id),
          path("${patient_id}_pass.vcf.gz"),
          path("${patient_id}_pass.vcf.gz.tbi")

    script:
    """
    gatk SelectVariants \
        -V $filtered_vcf \
        --exclude-filtered \
        -O ${patient_id}_pass.vcf.gz

    gatk IndexFeatureFile \
        -I ${patient_id}_pass.vcf.gz
    """
}
// In VCF terminology, variants that fail are assigned FILTER labels (e.g., weak_evidence or contamination), while accepted variants are labeled PASS; --exclude-filtered removes the failed/filtered variants and keeps the PASS variants.
