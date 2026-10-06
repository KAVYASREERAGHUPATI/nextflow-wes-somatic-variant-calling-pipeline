// Step 1: Reference Preparation
// Creates the FASTA index, GATK sequence dictionary, and BWA-MEM2 index required before read alignment and GATK-based variant analysis.

process PREPARE_REFERENCE {

    container "melanoma-wes:1.0"

    input:
    path ref

    output:
    tuple path("genome.fa"),
          path("genome.fa.0123"),
          path("genome.fa.amb"),
          path("genome.fa.ann"),
          path("genome.fa.bwt.2bit.64"),
          path("genome.fa.pac"),
          emit: bwa_ref

    tuple path("genome.fa"),
          path("genome.fa.fai"),
          path("genome.dict"),
          emit: gatk_ref

    script:
    """
    samtools faidx genome.fa

    gatk CreateSequenceDictionary \
        -R genome.fa \
        -O genome.dict

    bwa-mem2 index genome.fa
    """
}

// faidx = FASTA index for efficient random access to reference sequences.
// .fai is a coordinate-access index.
//
// BWA-MEM2 index = creates the index files required for efficient
// alignment of sequencing reads against the reference genome.
//
// .dict = sequence dictionary describing reference contigs,
// their names, lengths, and order.
