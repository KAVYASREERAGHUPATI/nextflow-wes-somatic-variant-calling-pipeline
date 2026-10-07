// ============================================================
// Nextflow WES Somatic Variant Calling Pipeline
// Main workflow: defines input channels and connects all modules
// ============================================================


// ------------------------------------------------------------
// PARAMETERS
// ------------------------------------------------------------

params.reference = "reference/genome.fa"
params.input = "samplesheet.csv"

params.dbsnp = "reference/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
params.dbsnp_index = "reference/Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi"

params.mills = "reference/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
params.mills_index = "reference/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi"
//We use dbSNP and Mills/1000G indel VCFs as known variant sites so BQSR does not mistake real SNPs and indels for sequencing errors while learning the error pattern.

params.vep_cache = "reference/vep_cache"

params.gnomad = "reference/af-only-gnomad.hg38.vcf.gz"
params.gnomad_index = "reference/af-only-gnomad.hg38.vcf.gz.tbi"

params.pon = "reference/1000g_pon.hg38.vcf.gz"
params.pon_index = "reference/1000g_pon.hg38.vcf.gz.tbi"

params.trimmomatic_adapters = "/usr/share/trimmomatic/TruSeq3-PE.fa"
//the above file will directly get if we install trimmomatic in the docker, so no need of params.value


// ------------------------------------------------------------
// MODULES
// ------------------------------------------------------------

include { PREPARE_REFERENCE }           from './modules/prepare_reference'
include { FASTQC }                     from './modules/fastqc'
include { TRIMMOMATIC }                from './modules/trimmomatic'
include { FASTQC_TRIMMED }             from './modules/fastqc_trimmed'
include { ALIGN_BWA }                  from './modules/align_bwa'
include { MARK_DUPLICATES }            from './modules/mark_duplicates'
include { BASERECALIBRATOR }           from './modules/base_recalibrator'
include { APPLY_BQSR }                 from './modules/apply_bqsr'
include { MUTECT2 }                    from './modules/mutect2'
include { FILTER_MUTECT_CALLS }        from './modules/filter_mutect_calls'
include { SELECT_PASS_VARIANTS }       from './modules/select_pass_variants'
include { VEP_ANNOTATION }             from './modules/vep_annotation'
include { VEP_TO_TABLE }               from './modules/vep_to_table'
include { MERGE_COHORT_VARIANTS }      from './modules/merge_cohort_variants'
include { FILTER_FUNCTIONAL_VARIANTS } from './modules/filter_functional_variants'
include { FILTER_POPULATION_AF }       from './modules/filter_population_af'
include { MULTIQC }                    from './modules/multiqc'

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Output Management:-
//Final analysis outputs, including filtered VCF files, annotated variants, variant tables, cohort-level results, and MultiQC reports, are published to the `results/` directory.
//Large intermediate files generated during preprocessing steps, such as trimmed FASTQ files, aligned BAM files, duplicate-marked BAM files, and BQSR intermediate files, are not published to the `results/` directory because they are not required for downstream analysis. These files remain temporarily available in the Nextflow `work/` directory and are automatically passed between pipeline processes.
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// ------------------------------------------------------------
// **WORKFLOW**
// ------------------------------------------------------------

workflow {

    // --------------------------------------------------------
    // Input sample channel
    // --------------------------------------------------------

    reads_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.patient_id,
                row.sample_type,
                file(row.r1),
                file(row.r2)
            )
        }


    // --------------------------------------------------------
    // Reference and resource channels
    // --------------------------------------------------------

    reference_ch = Channel.value(file(params.reference))

    dbsnp_ch = Channel.value(file(params.dbsnp))
    dbsnp_index_ch = Channel.value(file(params.dbsnp_index))

    mills_ch = Channel.value(file(params.mills))
    mills_index_ch = Channel.value(file(params.mills_index))

    vep_cache_ch = Channel.value(file(params.vep_cache))

    gnomad_ch = Channel.value(
        tuple(
            file(params.gnomad),
            file(params.gnomad_index)
        )
    )

    pon_ch = Channel.value(
        tuple(
            file(params.pon),
            file(params.pon_index)
        )
    )


    // --------------------------------------------------------
    // Step 1: Reference preparation
    // --------------------------------------------------------

    PREPARE_REFERENCE(reference_ch)


    // --------------------------------------------------------
    // Step 2: Raw-read quality control
    // --------------------------------------------------------

    FASTQC(reads_ch)


    // --------------------------------------------------------
    // Step 3: Adapter and quality trimming
    // --------------------------------------------------------

    TRIMMOMATIC(reads_ch)


    // --------------------------------------------------------
    // Step 4: Post-trimming quality control
    // --------------------------------------------------------

    FASTQC_TRIMMED(
        TRIMMOMATIC.out.paired_reads
    )


    // --------------------------------------------------------
    // Step 5: BWA-MEM2 alignment
    // --------------------------------------------------------

    ALIGN_BWA(
        TRIMMOMATIC.out.paired_reads,
        PREPARE_REFERENCE.out.bwa_ref
    )

    //TRIMMOMATIC.out.paired_reads means (patient_id, sample_type, R1_paired, R2_paired) we are passing the surviving R1 and R2 mate files together to BWA-MEM2.
    // --------------------------------------------------------
    // Step 6: Duplicate marking
    // --------------------------------------------------------

    MARK_DUPLICATES(
        ALIGN_BWA.out
    )


    // --------------------------------------------------------
    // Step 7: BaseRecalibrator
    // --------------------------------------------------------

    bqsr_input_ch = MARK_DUPLICATES.out.map {
        patient_id, sample_type, marked_bam, bai, metrics ->

        tuple(
            patient_id,
            sample_type,
            marked_bam,
            bai
        )
    }

    BASERECALIBRATOR(
        bqsr_input_ch,
        PREPARE_REFERENCE.out.gatk_ref,
        dbsnp_ch,
        dbsnp_index_ch,
        mills_ch,
        mills_index_ch
    )

    // Alternatively, we can pass marked_bam and bai directly through the BaseRecalibrator output tuple, avoiding this join step.
    // --------------------------------------------------------
    // Step 8: Apply BQSR
    // --------------------------------------------------------

    apply_bqsr_input_ch = bqsr_input_ch.join(
        BASERECALIBRATOR.out,
        by: [0, 1]
    )

    APPLY_BQSR(
        apply_bqsr_input_ch,
        PREPARE_REFERENCE.out.gatk_ref
    )


    // --------------------------------------------------------
    // Step 9: Matched tumor-normal pairing
    // --------------------------------------------------------

    tumor_ch = APPLY_BQSR.out.filter {
        patient_id, sample_type, bam, bai ->
        sample_type == "tumor"
    }

    normal_ch = APPLY_BQSR.out.filter {
        patient_id, sample_type, bam, bai ->
        sample_type == "normal"
    }
    // Separate tumor and normal recalibrated BAMs from APPLY_BQSR.out so they can be paired by patient_id for matched tumor-normal Mutect2 analysis.
    
    paired_ch = tumor_ch.join(
        normal_ch,
        by: 0
    )


    // --------------------------------------------------------
    // Step 10: Somatic variant calling
    // --------------------------------------------------------

    MUTECT2(
        paired_ch,
        PREPARE_REFERENCE.out.gatk_ref,
        gnomad_ch,
        pon_ch
    )


    // --------------------------------------------------------
    // Step 11: Mutect2 variant filtering
    // --------------------------------------------------------

    FILTER_MUTECT_CALLS(
        MUTECT2.out,
        PREPARE_REFERENCE.out.gatk_ref
    )


    // --------------------------------------------------------
    // Step 12: PASS variant selection
    // --------------------------------------------------------

    SELECT_PASS_VARIANTS(
        FILTER_MUTECT_CALLS.out
    )


    // --------------------------------------------------------
    // Step 13: VEP annotation
    // --------------------------------------------------------

    vep_reference_ch = PREPARE_REFERENCE.out.gatk_ref.map {
        ref, fai, dict ->
        tuple(ref, fai)
    }

    VEP_ANNOTATION(
        SELECT_PASS_VARIANTS.out,
        vep_cache_ch,
        vep_reference_ch
    )


    // --------------------------------------------------------
    // Step 14: Annotated variant table generation
    // --------------------------------------------------------

    VEP_TO_TABLE(
        VEP_ANNOTATION.out
    )


    // --------------------------------------------------------
    // Step 15: Cohort-level variant table
    // --------------------------------------------------------

    cohort_variant_files = VEP_TO_TABLE.out
        .map { patient_id, variants_tsv ->
            variants_tsv
        }
        .collect()

    MERGE_COHORT_VARIANTS(
        cohort_variant_files
    )


    // --------------------------------------------------------
    // Step 16: Functional variant filtering
    // --------------------------------------------------------

    FILTER_FUNCTIONAL_VARIANTS(
        VEP_TO_TABLE.out
    )


    // --------------------------------------------------------
    // Step 17: Population allele-frequency filtering
    // --------------------------------------------------------

    FILTER_POPULATION_AF(
        FILTER_FUNCTIONAL_VARIANTS.out
    )


    // --------------------------------------------------------
    // Step 18: MultiQC report generation
    // --------------------------------------------------------

    raw_qc_files = FASTQC.out
        .map { patient_id, sample_type, html, zip ->
            tuple(html, zip)
        }
        .flatten()

    trimmed_qc_files = FASTQC_TRIMMED.out
        .map { patient_id, sample_type, html, zip ->
            tuple(html, zip)
        }
        .flatten()

    duplicate_qc_files = MARK_DUPLICATES.out
        .map { patient_id, sample_type, marked_bam, bai, metrics ->
            metrics
        }

    all_qc_files = raw_qc_files
        .mix(trimmed_qc_files)
        .mix(duplicate_qc_files)
        .collect()

    MULTIQC(
        all_qc_files
    )
}


// Source channels can be defined outside workflow; channels derived from process outputs are created inside workflow after those processes are invoked.
// Pipeline: FASTQ → FastQC → Trimmomatic → FastQC → BWA-MEM2 → MarkDuplicates → BQSR → Tumor-Normal Pairing → Mutect2 → FilterMutectCalls → PASS Variants → VEP Annotation → Variant TSV → Cohort Variant Table -> multiQC report
// COSMIC_ANNOTATION: Annotates somatic variants with COSMIC evidence to identify variants previously reported in cancer, but not included in pipeline
// Publish filtered VCFs, PASS VCFs, VEP annotations, variant/functional/rare tables, cohort variants  and MultiQC results to organized results directories.
