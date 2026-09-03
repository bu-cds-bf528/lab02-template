#!/usr/bin/env nextflow

nextflow.enable.types = true

process NCBI_DATASETS_CLI {
    label 'process_single'

    // TODO: specify the conda environment this process should use

    output:
    // TODO: declare the output path for the downloaded genome

    script:
    """
    // TODO: use the ncbi-datasets-cli tool to download the E. coli genome
    // and unzip the resulting archive
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
    gc: Path

    output:
    stdout

    script:
    """
    echo "GC Content"
    cat $gc
    """

}

process PRINT_LENGTH {

    input:
    length: Path

    output:
    stdout

    script:
    """
    echo "Length"
    cat $length
    """

}


workflow {
    main:
    // TODO: call NCBI_DATASETS_CLI, then GENOME_STATS on its output
    // TODO: send the appropriate outputs of GENOME_STATS to PRINT_GC and PRINT_LENGTH

    publish:
    // TODO: assign the outputs you want published to a name, e.g. some_name = stats.some_output
}

output {
    // TODO: add an entry for each name assigned under publish, e.g. some_name {}
}
