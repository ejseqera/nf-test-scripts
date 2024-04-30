#!/usr/bin/env nextflow

include { COLLECT_FILES  } from './subworkflows/collect.nf'

workflow {
    values = Channel.of('alpha', 'beta', 'gamma')
    values.collectFile(name: 'combined.txt', storeDir: "${params.outdir}/combined", sort: false, newLine: true)
}