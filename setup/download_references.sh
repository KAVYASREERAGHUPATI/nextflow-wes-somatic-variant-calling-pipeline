#!/bin/bash

# Download GRCh38 reference resources required by the WES somatic variant calling pipeline

set -e

mkdir -p reference
cd reference

# Human reference genome
wget https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta
mv Homo_sapiens_assembly38.fasta genome.fa

# dbSNP known sites for BQSR
wget https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz
wget https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi

# Mills/1000G indels known sites for BQSR
wget https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
wget https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi

# gnomAD germline resource for Mutect2
wget https://storage.googleapis.com/gatk-best-practices/somatic-hg38/af-only-gnomad.hg38.vcf.gz
wget https://storage.googleapis.com/gatk-best-practices/somatic-hg38/af-only-gnomad.hg38.vcf.gz.tbi

# Panel of Normals for Mutect2
wget https://storage.googleapis.com/gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz
wget https://storage.googleapis.com/gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz.tbi

echo "Reference resources downloaded successfully."
# ------------------------------------------------------------
# Ensembl VEP Cache
# ------------------------------------------------------------
# The pipeline also requires an Ensembl VEP cache for offline functional annotation of somatic variants.
# VEP software is installed in the Docker image.
# The VEP cache is stored separately and should be placed under: reference/vep_cache/
# The cache is not included in this script because it is a large external resource and is automatically downloaded using docker image separately.
