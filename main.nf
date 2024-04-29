#!/usr/bin/env nextflow

process foo {
  debug true

  script:
    """
    echo "The value of TOWER_ACCESS_TOKEN is: $TOWER_ACCESS_TOKEN"
    """
}

process test_cli {
    debug true
    container 'quay.io/seqeralabs/nf-aggregate:tower-cli-0.9.0--2cb0f2e9d85d026b'

    script:
    """
    tw \\
        --url=https://api.cloud.seqera.io \\
        --access-token=$TOWER_ACCESS_TOKEN \\
        workspaces \\
        list \\
        --organization=scidev
    """
}

workflow {
  foo()
  test_cli()
}
