process TEST_CREATE_FILE {
    /*
    Creates a file on the worker node which is uploaded to the working directory.
    */

    output:
        path("*.txt"), emit: outfile

    """
    echo "test" > test.txt
    """
}

process TEST_CREATE_EMPTY_FILE {
    /*
    Creates an empty file on the worker node which is uploaded to the working directory.
    */

    output:
        path("*.txt"), emit: outfile

    """
    touch test.txt
    """
}

process TEST_CREATE_FOLDER {
    /*
    Creates a file on the worker node which is uploaded to the working directory.
    */

    output:
        path("test"), type: 'dir', emit: outfolder

    """
    mkdir -p test
    echo "test1" > test/test1.txt
    echo "test2" > test/test2.txt
    """
}


process TEST_STAGE_REMOTE {
    /*
    Stages a file from a remote file to the worker node.
    */

    input:
        path input

    output:
        stdout

    """
    cat $input
    """
}

process TEST_PUBLISH_FILE {
    /*
    Creates a file on the worker node and uploads to the publish directory.
    */


    publishDir { params.outdir ?: file(workflow.workDir).resolve("outputs").toUriString()  }, mode: 'copy'

    output:
        path("*.txt")

    """
    touch test.txt
    """
}


workflow NF_CANARY {

    main:
        // Create test file on head node
        Channel
            .of("alpha", "beta", "gamma")
            .collectFile(name: 'sample.txt', newLine: true)
            .set { test_file }

        remote_file = params.remoteFile ? Channel.fromPath(params.remoteFile) : Channel.empty()

        // Run tests
        TEST_CREATE_FILE()
        TEST_CREATE_EMPTY_FILE()
	    TEST_CREATE_FOLDER()
        TEST_STAGE_REMOTE(remote_file)
        TEST_PUBLISH_FILE()
        
        // POC of emitting the channel
        Channel.empty()
            .mix(
                TEST_CREATE_FILE.out,
                TEST_CREATE_EMPTY_FILE.out,
                TEST_CREATE_FOLDER.out,
                TEST_STAGE_REMOTE.out,
                TEST_PUBLISH_FILE.out,
            )
            .set { ch_out }

    emit:
        out = ch_out
}

workflow {
    NF_CANARY()
}
