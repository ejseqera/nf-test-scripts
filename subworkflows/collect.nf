#!/usr/bin/env nextflow

workflow COLLECT_FILES {
    take:
        ch_collect
        outdir

    main:
        ch_collect.collectFile(name: 'combined.txt', storeDir: "${outdir}/combined")
}