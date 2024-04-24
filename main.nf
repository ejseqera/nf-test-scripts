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
    remote_file = params.remoteFile ? Channel.fromPath(params.remoteFile).collect() : Channel.empty()
    STAGE_FILE(remote_file)
    ch_moved = MOVE_FILE(remote_file)
    ch_moved.view()
}
