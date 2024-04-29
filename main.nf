#!/usr/bin/env nextflow

process foo {
  debug true

  script:
    """
    echo "The value of TOKEN_VALUE is: $TOKEN_VALUE"
    """
}

workflow {
  foo()
}
