#!/usr/bin/env nextflow

include { COLLECT_FILES  } from './subworkflows/collect.nf'

workflow {
    ch_collect = Channel.of('alpha', 'beta', 'gamma')
    COLLECT_FILES(ch_collect, params.outdir)
}