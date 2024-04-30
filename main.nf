#!/usr/bin/env nextflow

include { COLLECT_FILES  } from './subworkflows/collect.nf'

workflow {
    values = Channel.of('alpha', 'beta', 'gamma')
    values.collectFile(name: 'combined.txt', storeDir: "${params.outdir}/combined", sort: false, newLine: true)
}

workflow {
    values = Channel.of('a', 'b')
    values.collectFile(name: "file.txt", storeDir: "gs://nxf-work/trash", sort: false, newLine: true)
}