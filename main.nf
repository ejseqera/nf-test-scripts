#!/usr/bin/env nextflow

process generateTag {
    tag "${samples}"

    input:
    val samples

    script:
    """
    echo "Processing sample: ${samples}"
    """
}
workflow {
    samples = Channel.of("BRD1_S1, Homo_sapiens.10__with--invalid__chars")
    generateTag(samples)
}