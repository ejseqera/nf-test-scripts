#!/usr/bin/env nextflow

include { COLLECT_FILES  } from './subworkflows/collect.nf'

workflow {
    Channel.of('alpha', 'beta', 'gamma')
    .collectFile(name: 'combined.txt', sort: true, storeDir: "${params.outdir}/combined")
}