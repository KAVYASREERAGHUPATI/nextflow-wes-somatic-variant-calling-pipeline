# nextflow-wes-somatic-variant-calling-pipeline
Reproducible Nextflow DSL2 pipeline for tumor-normal WES, integrating QC, BWA-MEM2 alignment, GATK preprocessing, Mutect2 somatic variant calling, VEP annotation, variant filtering, and MultiQC reporting.

# Nextflow WES Somatic Variant Calling Pipeline
This repository contains a reproducible **Nextflow DSL2 pipeline for somatic variant calling from paired tumor-normal whole-exome sequencing (WES) data**.

The pipeline performs quality control, read preprocessing, alignment, duplicate marking, base quality score recalibration, somatic variant calling, variant filtering, functional annotation, cohort-level table generation, and quality-control reporting.

The workflow is modular and can be adapted for other paired tumor-normal WES datasets.

## Computational Environment

The pipeline was executed on a **Microsoft Azure Virtual Machine (VM)** using the following configuration:

| Component | Configuration |
|---|---|
| Cloud Platform | Microsoft Azure |
| Virtual Machine | Standard_FX32-16ms_v2 |
| vCPUs | 16 |
| Memory (RAM) | 672 GiB |
| Operating System Disk | 256 GB |
| Data Storage Disk | 3.5 TB |
| Operating System | Ubuntu Server 24.04 LTS (64-bit) |
| Workflow Management | Nextflow |
| Containerization | Docker |
| SSH Client | PuTTY |
| File Transfer | WinSCP |

These specifications represent the cloud environment used for this project. The Nextflow workflow itself can be adapted to other computational environments with appropriate CPU, memory, storage, and software configuration.

Note: The above computational configuration was successfully used on Microsoft Azure to process paired tumor-normal WES data from 54 patients (108 samples) through the complete Nextflow somatic variant-calling pipeline.


## Step 1: Prepare the Input Files

The pipeline requires paired-end tumor and matched-normal WES FASTQ files.

Sample information is provided through a CSV samplesheet containing the patient ID, sample type, and paired FASTQ file paths.

The matched-normal samples are used during somatic variant calling to help distinguish tumor-specific candidate somatic variants from germline variation.

## Step 2: Configure the Nextflow Pipeline

The `nextflow.config` file defines the computational and execution settings used by the workflow.

The configuration can be modified according to the available computational environment and resources.

## Step 3: Main Nextflow Workflow

The `main.nf` file defines the overall workflow and connects the individual processes of the WES pipeline.

It controls the movement of data from raw paired-end FASTQ files through preprocessing, alignment, variant calling, filtering, annotation, and final output generation.


## Step 4: WES Somatic Variant Calling Workflow

The pipeline performs the following major steps:

1. Reference genome preparation
2. Raw-read quality control using FastQC
3. Adapter and quality trimming using Trimmomatic
4. Post-trimming quality control using FastQC
5. Alignment to the GRCh38 reference genome using **BWA-MEM2**
6. Duplicate marking
7. Base Quality Score Recalibration (BQSR)
8. Tumor-normal somatic variant calling using **GATK Mutect2**
9. Variant filtering using GATK FilterMutectCalls
10. PASS variant selection
11. Variant annotation using Ensembl VEP
12. Conversion of annotated variants into tabular format
13. Functional variant filtering
14. Population allele-frequency filtering
15. Cohort-level variant table generation
16. MultiQC reporting


## Step 5: Variant Annotation and Filtering

High-confidence PASS somatic variants are annotated using **Ensembl Variant Effect Predictor (VEP)**.

The resulting annotations include information such as:

- Gene and gene symbol
- Variant consequence
- VEP impact
- Coding and protein changes
- Population allele frequency
- Clinical significance
- Canonical transcript
- MANE Select transcript

Functional variants are selected based on protein-altering consequences, including missense, frameshift, stop-gained, stop-lost, start-lost, splice-site, and in-frame variants.

Population allele-frequency information is subsequently used to obtain rare functional variants.

---

## Step 6: Pipeline Outputs

The pipeline generates:

- FastQC reports
- Trimmed paired-end FASTQ files
- Aligned and processed BAM files
- Unfiltered somatic VCF files
- Filtered somatic VCF files
- PASS somatic VCF files
- VEP-annotated VCF files
- Per-patient variant tables
- Functional variant tables
- Rare functional variant tables
- Cohort-level variant table
- MultiQC report


## Application

The pipeline was built, tested, and executed using paired **tumor and matched-normal whole-exome sequencing data from an advanced melanoma immunotherapy cohort**.

The resulting somatic variant profiles are intended for downstream integration with tumor RNA-seq and clinical treatment-response data for multi-omics analysis.
