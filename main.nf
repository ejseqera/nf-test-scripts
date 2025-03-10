process COPY_FILES {
    input:
        path files
    output:
        path("outdir", type: 'dir')
    script:
    """
    mkdir -p outdir
    for f in ${files}; do
        cp \$f outdir/
    done
    """
}

process LIST_FILES {
    input:
        path files

    output:
        path "out", type: 'dir'
    """
    cp -rL $files out
    """
}

workflow {
    input_ch = Channel.fromPath(params.input).collect()
    output_ch = COPY_FILES(input_ch)
    LIST_FILES(output_ch)
}