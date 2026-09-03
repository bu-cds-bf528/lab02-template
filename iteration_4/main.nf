#!/usr/bin/env nextflow

nextflow.enable.types = true

process DOWNLOAD {

    output:
    Path = file("GCF_000005845.2_ASM584v2_genomic.fna.gz")

    script:
    """
    wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
    """

}

process GC_CONTENT {

    conda 'envs/biopython_env.yml'

    input:
    // TODO: declare a typed input for the downloaded genome

    output:
    // TODO: declare the output path

    script:
    """
    // TODO: call gc_content.py, passing the input and output file names as flags
    """

}

workflow {
    // TODO: assign the output of DOWNLOAD() to a variable and pass it into GC_CONTENT

}