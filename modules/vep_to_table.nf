// Step 13: Variant Table Generation
// Converts VEP-annotated VCF files into structured patient-level TSV tables for downstream analysis.

process VEP_TO_TABLE {

    publishDir "${baseDir}/results/tables/variants", mode: 'copy'
    container "melanoma-wes:1.0"

    input:
    tuple val(patient_id), path(vep_vcf), path(vep_vcf_index)

    output:
    tuple val(patient_id),
          path("${patient_id}_variants.tsv")

    script:
    """
    echo -e "Patient_ID\\tChromosome\\tPosition\\tREF\\tALT\\tTumor_AF\\tgnomADe_AF\\tGene\\tSYMBOL\\tFeature\\tConsequence\\tIMPACT\\tCLIN_SIG\\tHGVSc\\tHGVSp\\tCANONICAL\\tMANE_SELECT" \
        > ${patient_id}_variants.tsv

    bcftools view \
        -s ${patient_id}_tumor \
        $vep_vcf \
        -Ou | \
    bcftools +split-vep - \
        -s primary \
        -f "${patient_id}\\t%CHROM\\t%POS\\t%REF\\t%ALT\\t[%AF]\\t%gnomADe_AF\\t%Gene\\t%SYMBOL\\t%Feature\\t%Consequence\\t%IMPACT\\t%CLIN_SIG\\t%HGVSc\\t%HGVSp\\t%CANONICAL\\t%MANE_SELECT\\n" \
        >> ${patient_id}_variants.tsv
    """
}
//-s primary will give only one transcript (canonical=YES), without will give us multiple transcript names and their annotations
// + means a bcftools plugin; split-vep splits/extracts VEP's CSQ (Consequence) annotation fields into separate values/columns;> = overwrite/create >>  = append
// VEP file format    CHROM POS   REF ALT   INFO/CSQ                     FORMAT     35_067_tumor   35_067_normal
//                    chr7  10000 A   T     BRAF|missense|MODERATE|...   GT:AD:AF   0/1:60,40:.40  0/0:98,2:.02
