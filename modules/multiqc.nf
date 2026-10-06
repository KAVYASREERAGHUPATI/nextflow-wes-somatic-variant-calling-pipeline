// Step 17: Quality Control Summary
// Aggregates pipeline quality-control outputs into a single MultiQC report.

process MULTIQC {

    publishDir "${baseDir}/results/multiqc", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    path qc_files

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    multiqc . --force
    """
}
