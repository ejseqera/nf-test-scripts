#!/usr/bin/env nextflow

// Reproduces sarek's versions + multiqc_files channel construction exactly
// Key: deeply nested mix chain (empty → mix × N) with topic, then toList → map → collectFile

process PROC_A {
    input: val(s)
    output:
        path("${s}_a_report.txt"), emit: reports
        tuple val(task.process), val('tool_a'), eval('echo v1.0'), topic: 'versions'
        tuple val(task.process), val('tool_a'), path("${s}_a_mqc.txt"), topic: 'multiqc_files'
    script: "touch ${s}_a_report.txt ${s}_a_mqc.txt"
}

process PROC_B {
    input: val(s)
    output:
        path("${s}_b_report.txt"), emit: reports
        tuple val(task.process), val('tool_b'), eval('echo v2.0'), topic: 'versions'
        tuple val(task.process), val('tool_b'), path("${s}_b_mqc.txt"), topic: 'multiqc_files'
    script: "touch ${s}_b_report.txt ${s}_b_mqc.txt"
}

process PROC_C {
    input: val(s)
    output:
        path("${s}_c_report.txt"), emit: reports
        tuple val(task.process), val('tool_c'), eval('echo v3.0'), topic: 'versions'
        tuple val(task.process), val('tool_c'), path("${s}_c_mqc.txt"), topic: 'multiqc_files'
    script: "touch ${s}_c_report.txt ${s}_c_mqc.txt"
}

process MULTIQC {
    debug true
    input: path('files/*')
    script: "echo 'MultiQC done: \$(ls files/)'"
}

workflow SUB_A {
    take: samples
    main: PROC_A(samples)
    emit: reports = PROC_A.out.reports
}

workflow SUB_B {
    take: samples
    main: PROC_B(samples)
    emit: reports = PROC_B.out.reports
}

workflow SUB_C {
    take: samples
    main: PROC_C(samples)
    emit: reports = PROC_C.out.reports
}

workflow {
    samples = channel.of('s1', 's2', 's3')

    SUB_A(samples)
    SUB_B(samples)
    SUB_C(samples)

    // Mimic sarek's versions channel accumulated from sub-workflows (they emit via topic)
    // Then softwareVersionsToYAML does: versions.mix(topic).toList().map{...}.collectFile(...)
    ch_versions = channel.topic('versions')
        .toList()
        .map { v -> v.collect { t -> "${t[1]}: ${t[2]}" }.join('\n') }
        .collectFile(name: 'software_versions.yaml', sort: true, newLine: true)

    // Mimic sarek's reports channel: start empty, accumulate
    reports = channel.empty()
    reports = reports.mix(SUB_A.out.reports)
    reports = reports.mix(SUB_B.out.reports)
    reports = reports.mix(SUB_C.out.reports)

    // Mimic sarek's ch_workflow_summary: value → collectFile
    ch_summary = channel.value('workflow: test\n')
        .collectFile(name: 'workflow_summary.yaml')

    // Mimic sarek's methods description: value → collectFile
    ch_methods = channel.value('methods: test\n')
        .collectFile(name: 'methods_description.yaml')

    // Mimic sarek's ch_multiqc_files construction (5 mix sources)
    ch_multiqc = channel.empty()
    ch_multiqc = ch_multiqc.mix(ch_summary)
    ch_multiqc = ch_multiqc.mix(ch_versions)
    ch_multiqc = ch_multiqc.mix(reports)
    ch_multiqc = ch_multiqc.mix(
        channel.topic('multiqc_files').map { _p, _t, r -> r }
    )
    ch_multiqc = ch_multiqc.mix(ch_methods)

    MULTIQC(ch_multiqc.collect())
}
