#!/usr/bin/env nextflow

/*
 * MRE for https://github.com/nextflow-io/nextflow/issues/7029
 *
 * Reproduces the nf-core/sarek 3.8.1 MultiQC channel hang pattern:
 * collect() never fires after all upstream tasks complete on 26.03.x-edge.
 *
 * Self-contained — no input files needed. Works on any executor.
 *
 * NOTE: Does not reproduce locally (local executor). Must run on cloud
 *       (AWS Batch / Google Batch) to trigger the hang.
 *
 * Run with:
 *   NXF_VER=25.10.4 nextflow run mre-7029.nf -profile cloud    # works: MULTIQC fires
 *   NXF_VER=26.03.0-edge nextflow run mre-7029.nf -profile cloud  # hangs: MULTIQC never runs
 *
 * The pipeline stalls with:
 *   "No more task to compute -- The following nodes are still active:
 *    [process] MULTIQC  status=ACTIVE  port 0: (value) OPEN"
 */

// ─── Processes ────────────────────────────────────────────────────────────────

process FASTQC {
    input:  val(sample_id)
    output:
        path("${sample_id}_fastqc.zip"), emit: zip
        tuple val(task.process), val('fastqc'), eval('echo 0.12.1'), topic: 'versions'
    script:
    """
    touch ${sample_id}_fastqc.zip
    """
}

process MARKDUPLICATES {
    input:  val(sample_id)
    output:
        path("${sample_id}_markdup.txt"), emit: metrics
        tuple val(task.process), val('picard'), eval('echo 3.1.0'), topic: 'versions'
    script:
    """
    touch ${sample_id}_markdup.txt
    """
}

process BCFTOOLS_STATS {
    input:  val(sample_id)
    output:
        path("${sample_id}_bcftools.txt"), emit: stats
        tuple val(task.process), val('bcftools'), eval('echo 1.18'), topic: 'versions'
    script:
    """
    touch ${sample_id}_bcftools.txt
    """
}

process MULTIQC {
    debug true
    input:
        path('multiqc_files/*')
        val(config)
    script:
    """
    echo "MultiQC ran with: \$(ls multiqc_files/)"
    """
}

// ─── Sub-workflows ─────────────────────────────────────────────────────────────

workflow FASTQ_PREPROCESS {
    take: samples
    main:
        FASTQC(samples)
    emit:
        reports = FASTQC.out.zip
}

workflow BAM_QC {
    take: samples
    main:
        MARKDUPLICATES(samples)
    emit:
        reports = MARKDUPLICATES.out.metrics
}

workflow VCF_QC {
    take: samples
    main:
        BCFTOOLS_STATS(samples)
    emit:
        reports = BCFTOOLS_STATS.out.stats
}

// ─── Entry workflow ─────────────────────────────────────────────────────────────
//
// Mirrors nf-core/sarek 3.8.1 MultiQC channel construction:
//   https://github.com/nf-core/sarek/blob/3.8.1/workflows/sarek/main.nf#L604-L631

workflow {
    samples = channel.of('sample1', 'sample2', 'sample3')

    FASTQ_PREPROCESS(samples)
    BAM_QC(samples)
    VCF_QC(samples)

    // Mirror sarek's `reports` channel: start empty, accumulate via mix
    reports = channel.empty()
    reports = reports.mix(FASTQ_PREPROCESS.out.reports)
    reports = reports.mix(BAM_QC.out.reports)
    reports = reports.mix(VCF_QC.out.reports)

    // Mirror sarek's ch_workflow_summary: value channel → collectFile
    ch_workflow_summary = channel.value('workflow: sarek\nversion: 3.8.1\n')
        .collectFile(name: 'workflow_summary_mqc.yaml')

    // Mirror sarek's version_yaml: topic channel → collectFile
    ch_versions = channel.topic('versions')
        .collectFile(name: 'software_versions.yaml', sort: true, newLine: true)

    // Mirror sarek's ch_multiqc_files: accumulated from all sources
    ch_multiqc_files = channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary)
    ch_multiqc_files = ch_multiqc_files.mix(ch_versions)
    ch_multiqc_files = ch_multiqc_files.mix(reports)
    ch_multiqc_files = ch_multiqc_files.mix(
        channel.topic('multiqc_files').map { _process, _tool, report -> report }
    )

    // The hang: collect() never fires on 26.03.x-edge with cloud executors
    MULTIQC(
        ch_multiqc_files.collect(),
        'multiqc_config.yaml',
    )
}
