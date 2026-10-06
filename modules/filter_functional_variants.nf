// Step 15: Functional Variant Filtering
// Retains protein-altering somatic variants based on VEP consequence annotations.

process FILTER_FUNCTIONAL_VARIANTS {

    publishDir "${baseDir}/results/tables/functional_variants", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), path(variants_tsv)

    output:
    tuple val(patient_id),
          path("${patient_id}_functional_variants.tsv")

    script:
    """
    awk -F '\\t' '
    NR==1 ||
    \$11 ~ /missense_variant|frameshift_variant|stop_gained|stop_lost|start_lost|splice_donor_variant|splice_acceptor_variant|inframe_insertion|inframe_deletion|protein_altering_variant/
    ' $variants_tsv > ${patient_id}_functional_variants.tsv
    """
}
// FILTER_FUNCTIONAL_VARIANTS: Retains protein-altering/functional somatic variants based on VEP consequence annotations.
