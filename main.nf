#!/usr/bin/env nextflow

include { COLLECT_FILES  } from './subworkflows/collect.nf'

workflow {
    values = Channel.of('a', 'b')
    values.collectFile(name: "file.txt", storeDir: "${params.outdir}", sort: false, newLine: true)
}