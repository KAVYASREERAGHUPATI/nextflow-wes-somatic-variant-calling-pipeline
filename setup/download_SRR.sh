#!/bin/bash

# Download WES data from NCBI SRA and convert to paired-end FASTQ.
# Required input: wes_accessions.txt containing one SRR accession per line.

set -e

# Check whether the WES accession file is available
if [[ -f wes_accessions.txt ]]; then
    echo "wes_accessions.txt found - proceeding with WES data download."
else
    echo "ERROR: wes_accessions.txt not found."
    echo "Please provide wes_accessions.txt with one SRR accession per line."
    exit 1
fi

mkdir -p sra fastq tmp


# Step 1: Prefetch SRA Runs

while read srr
do
    echo "Prefetching $srr"

    prefetch "$srr" \
        --output-directory sra

done < wes_accessions.txt



# Step 2: Convert SRA to Paired-End FASTQ

while read srr
do

    # Skip samples that were already processed
    if [[ -f fastq/${srr}_1.fastq.gz && -f fastq/${srr}_2.fastq.gz ]]; then
        echo "$srr already processed - skipping"
        continue
    fi

    echo "Converting $srr to FASTQ"

    fasterq-dump sra/$srr \
        --split-files \
        --outdir fastq \
        --temp tmp \
        -e 8

    echo "Compressing $srr"

    pigz -p 8 fastq/${srr}_1.fastq &
    pigz -p 8 fastq/${srr}_2.fastq &
    wait

    echo "$srr completed"

done < wes_accessions.txt

echo "WES data processing completed successfully."
