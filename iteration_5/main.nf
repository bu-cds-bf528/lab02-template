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

process GENOME_STATS {
    
    conda 'envs/biopython_env.yml'


    input:
    genome: Path

    output:
    length: Path = file('length.txt')
    gc_content: Path = file('gc_content.txt')

    script:
    """
    // TODO: call genome_stats.py with the appropriate flags
    """

}

process PRINT_GC {

    input:
    txt: Path

    output:
    stdout

    script:
    """
    echo "GC Content"
    cat $txt
    """

}

process PRINT_LENGTH {

    input:
    txt: Path

    output:
    stdout

    script:
    """
    echo "Length"
    cat $txt
    """

}

workflow {
    main:
    dl_genome = DOWNLOAD()
    stats = GENOME_STATS(dl_genome)
    // TODO: send the appropriate outputs of GENOME_STATS to PRINT_GC and PRINT_LENGTH

    publish:
    // TODO: assign the outputs you want published to a name, e.g. some_name = stats.some_output
}

output {
    // TODO: add an entry for each name assigned under publish, e.g. some_name {}
}