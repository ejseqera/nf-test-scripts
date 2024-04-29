#!/usr/bin/env nextflow

process foo {
  debug true

  script:
    """
    echo "The value of TOKEN_VALUE is: $TOKEN_VALUE"
    """
}

process test_cli {
    debug true
    container 'seqeralabs/nf-aggregate:tower-cli-0.9.0--2cb0f2e9d85d026b'

    script:
    """
    tw \\
        --url=https://api.cloud.seqera.io \\
        --access-token=\$TOKEN_VALUE \\
        workspaces \\
        list \\
        --organization=scidev
    """
}

workflow {
  foo()
  test_cli()
}
