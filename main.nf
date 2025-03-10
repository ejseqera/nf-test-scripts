process COPY_FILES {
    input:
        path files
    output:
        path output
    """
    cp $files $output
    """
}

process LIST_FILES {
    input:
        path files
    """
    echo $files
    """
}

workflow {
    input_ch = Channel.fromPath(params.input).collect()
    output_ch = COPY_FILES(input_ch)
    LIST_FILES(output_ch)
}