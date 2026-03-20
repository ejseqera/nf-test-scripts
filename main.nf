process MOVE_FILE {
     
    output: 
        path "test.txt"

    script:
    """
    touch test.txt
    exit 1
    """
}

workflow {
    MOVE_FILE()
}
