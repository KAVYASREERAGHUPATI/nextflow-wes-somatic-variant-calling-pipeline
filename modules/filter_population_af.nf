// Step 16: Population Allele-Frequency(AF) Filtering
// Retains rare functional variants with gnomAD exome AF < 0.01 or unavailable population frequency.

process FILTER_POPULATION_AF {

    publishDir "${baseDir}/results/tables/rare_variants", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), path(functional_tsv)

    output:
    tuple val(patient_id),
          path("${patient_id}_rare_variants.tsv")

    script:
    """
    awk -F '\\t' '
    NR == 1 ||
    \$7 == "." ||
    \$7 == "-" ||
    \$7 == "" ||
    \$7 < 0.01
    ' $functional_tsv > ${patient_id}_rare_variants.tsv
    """
}
// FILTER_POPULATION_AF: Retains rare variants based on gnomAD exome allele frequency (AF < 0.01 or unavailable).
