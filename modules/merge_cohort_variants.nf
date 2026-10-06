// Step 14: Cohort Variant Table Generation
// Merges all patient-level annotated variant tables into one cohort-level TSV for downstream cohort analysis.

process MERGE_COHORT_VARIANTS {

    publishDir "${baseDir}/results/cohort", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    path variant_files

    output:
    path "cohort_variants.tsv"

    script:
    """
    first_file=\$(echo $variant_files | awk '{print \$1}')

    head -n 1 \$first_file > cohort_variants.tsv

    for file in $variant_files
    do
        tail -n +2 \$file >> cohort_variants.tsv
    done
    """
}
// MERGE_COHORT_VARIANTS: Combines all patient-level annotated variant TSV files into a single cohort-level variant table, helps to know what kind of variations are predominant in all the samples
