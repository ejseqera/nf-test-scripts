process MOVE_FILE {
     
    output: 
        path "renamedtest.txt"

    """
    touch test.txt
    mv test.txt renamedtest.txt
    """
}

process MOVE_FILE_DIR {

    output:
        path("testdir"), type: 'dir', emit: outfolder 
    """
    mkdir -p testdir
    touch test.txt
    mv test.txt testdir/
    """
}

workflow {
    MOVE_FILE()
    MOVE_FILE_DIR()
}
