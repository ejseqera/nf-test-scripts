process READ_FILE {
    
    input:
        path input
    
    output:
        stdout

    """
    echo "Reading file: $input"
    cat $input
    """
}

process WRITE_FILE {
    
    publishDir params.outdir, mode: 'copy'

    output:
        path("test.txt")
    """
    touch test.txt
    """
}

workflow {
    log.info("The secret in Workflow is: ${secrets.ESHA_SECRET}")

    READ_FILE(params.infile)
    WRITE_FILE()
}
