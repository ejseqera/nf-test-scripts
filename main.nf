#!/usr/bin/env nextflow

process echoStuff {
    publishDir params.outDir
    
    output:
    path 'output.txt'

    script:
    """
    echo "Hello World" > output.txt
    """
}

workflow {
    echoStuff()
}
