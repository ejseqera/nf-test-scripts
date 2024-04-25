process STAGE_FILE {
    input:
        path input

    output: 
        path "renamed_test.txt"

    """
    mv "$input" renamed_test.txt
    """
}

process MOVE_FILE {
    input:
        path input

    output:
        path "outfile.txt", emit: outfile
    """
    cp "$input" outfile.txt
    """
}

workflow {
    values = Channel.of('a', 'b')
    values.collectFile(name: "file.txt", storeDir: params.outdir, sort: false, newLine: true)
}
