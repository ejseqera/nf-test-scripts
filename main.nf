process TEST_REMOTE_CONFIG {
    debug true

    script:
    """
    echo "Testing remote config inclusion with secrets..."
    echo "remoteConfigLoaded param: ${params.remoteConfigLoaded}"
    echo "foo param: ${params.foo}"
    echo "Process cpus: ${task.cpus}"
    echo "Process memory: ${task.memory}"
    """
}

workflow {
    TEST_REMOTE_CONFIG()
}
