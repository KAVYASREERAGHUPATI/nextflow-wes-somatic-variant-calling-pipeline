// Step 4: Post-Trimming Quality Control
// Runs FastQC on trimmed paired-end reads to verify read quality and adapter removal before alignment.

process FASTQC_TRIMMED {

    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), val(sample_type), path(r1), path(r2)

    output:
    tuple val(patient_id), val(sample_type),
          path("*_fastqc.html"),
          path("*_fastqc.zip")

    script:
    """
    fastqc $r1 $r2
    """
}
