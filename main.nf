pprocess mkfile {
    debug true
    output:
        path "test.txt"
    """
    echo "hello world" > test.txt
    """
}

process mvfile {
    debug true
    input:
        path infile
    output:
        path "outfile.txt"
    publishDir params.outdir
    """
    mv $infile outfile.txt
    """
}

workflow {
    mkfile | mvfile
}
