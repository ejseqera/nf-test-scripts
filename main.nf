process a {
    debug true
    input:
        path infile
    output:
        path "test.txt", emit: outfile
    script:
    """
    cat $infile || echo "input file $infile not found"
    echo "hello world!" > test.txt
    cat test.txt
    """
}

process b {
    publishDir "${params.outdir}"
    debug true
    input:
        path outfile
    output:
        path "publishmove", emit: publishmove
        path "publishnew", emit: publishnew
    script:
    """
    cat $outfile || echo "input file $outfile not found"
    mv $outfile ./publishmove
    cat ./publishmove
    echo "test" > ./publishnew
    """
}

workflow {
    a(params.infile) | b
}