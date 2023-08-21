process CREATE_FILE {
     
    output:
        path("*.txt"), emit: outfile

    """
    touch test.txt
    """
}

process MOVE_FILE {

    output:
        path("testdir"), type: dir, emit: outfolder 
    """
    mkdir -p testdir
    touch test.txt
    mv test.txt testdir/
    """
}

workflow {
    CREATE_FILE()
    MOVE_FILE()
}
