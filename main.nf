process LIST_FILES {
    input:
        path files
    """
    echo $files
    """
}

workflow {
    input_ch = Channel.fromPath(params.input).collect()
    LIST_FILES(input_ch)
}
