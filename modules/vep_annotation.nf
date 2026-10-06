// Step 12: Variant Annotation
// Annotates PASS somatic variants with VEP, including functional consequences and population allele frequencies.

process VEP_ANNOTATION {

    publishDir "${baseDir}/results/vep", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), path(pass_vcf), path(pass_vcf_index)
    path(vep_cache)
    tuple path(ref), path(ref_fai)
// The .dict is specifically part of the reference handling expected by GATK/Picard-style tools; we don't need to pass it into VEP.
    output:
    tuple val(patient_id),
          path("${patient_id}_vep.vcf.gz"),
          path("${patient_id}_vep.vcf.gz.tbi")

    script:
    """
    vep \
        --vcf \
        --input_file $pass_vcf \
        --output_file ${patient_id}_vep.vcf.gz \
        --compress_output bgzip \
        --cache \
        --dir_cache $vep_cache \
        --everything \
        --offline \
        --assembly GRCh38 \
        --fasta $ref \
        --af_gnomade \
        --force_overwrite

    tabix -p vcf ${patient_id}_vep.vcf.gz
    """
}
// gnomAD = Genome Aggregation Database; gnomADe_AF = population allele frequency from the gnomAD exome dataset.database contains allelic frequency of the population
