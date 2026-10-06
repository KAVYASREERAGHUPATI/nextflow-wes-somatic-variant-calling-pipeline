// Step 2: Raw Read Quality Control
// Runs FastQC on raw paired-end WES reads before trimming to assess sequencing quality.

process FASTQC {

    container 'melanoma-wes:1.0'

    input:
    tuple val(patient_id), val(sample_type), path(r1), path(r2)

    output:
    tuple val(patient_id), val(sample_type), path("*fastqc.html"), path("*fastqc.zip")

    script:
    """
    fastqc $r1 $r2
    """
}
