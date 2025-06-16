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
    READ_FILE(params.infile)
    WRITE_FILE()
}
