# Docker image for the Nextflow WES somatic variant calling pipeline
# Includes tools for QC, trimming, alignment, GATK processing,
# somatic variant calling, VEP annotation, and MultiQC reporting.

FROM ubuntu:24.04


# Install system dependencies and bioinformatics tools
RUN apt-get update && apt-get install -y \
    fastqc \
    trimmomatic \
    samtools \
    curl \
    bzip2 \
    tar \
    unzip \
    openjdk-17-jre-headless \
    perl \
    git \
    build-essential \
    cpanminus \
    libwww-perl \
    libdbi-perl \
    libdbd-mysql-perl \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    tabix \
    bcftools \
    python3 \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*
# bzip2 is required to decompress the .tar.bz2 archive used to install BWA-MEM2 (-j means using bzip2)
# tar -xjf - command, j tells tar to handle bzip2 compression.
# OpenJDK 17 provides the Java runtime required to run GATK
#Ensembl Variant Effect Predictor (Ensembl VEP)-(perl, git, build essential, cpanminus, libdbi-perl, libdbd-mysql-perl, zlib1g-dev)
# BCFtools is a command-line software package used to work with VCF/BCF variant files.


# Install BWA-MEM2 v2.2.1 for read alignment
RUN curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/bwa-mem2-2.2.1_x64-linux.tar.bz2 | tar -xjf - \
    && mv bwa-mem2-2.2.1_x64-linux /opt/bwa-mem2

ENV PATH="${PATH}:/opt/bwa-mem2"


# Install GATK v4.7.0.0 for BAM processing and somatic variant calling
RUN curl -L https://github.com/broadinstitute/gatk/releases/download/4.7.0.0/gatk-4.7.0.0.zip -o gatk.zip \
    && unzip gatk.zip \
    && mv gatk-4.7.0.0 /opt/gatk \
    && rm gatk.zip

ENV PATH="${PATH}:/opt/gatk"


# Install Ensembl Variant Effect Predictor (VEP), release 116
RUN git clone --branch release/116 --depth 1 \
    https://github.com/Ensembl/ensembl-vep.git /opt/vep

ENV PATH="${PATH}:/opt/vep"

RUN cd /opt/vep && perl INSTALL.pl --AUTO a


# Install MultiQC for aggregated quality-control reporting
RUN pip3 install multiqc --break-system-packages
