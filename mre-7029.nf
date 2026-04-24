#!/usr/bin/env nextflow

/*
 * MRE for https://github.com/nextflow-io/nextflow/issues/7029
 *
 * Mirrors nf-core/sarek 3.8.1 + nf-core-utils 0.4.0 MultiQC channel pattern exactly:
 *
 *   version_yaml = softwareVersionsToYAML(versions.mix(channel.topic("versions")))
 *                    .collectFile(storeDir:...)
 *
 *   softwareVersionsToYAML internally does:
 *     versions.toList().map{...}  → DataflowVariable-backed channel
 *
 *   ch_multiqc_files = channel.empty()
 *     .mix(ch_workflow_summary.collectFile(...))   ← value → collectFile
 *     .mix(version_yaml)                           ← DataflowVariable → collectFile → collectFile
 *     .mix(reports)
 *     .mix(channel.topic("multiqc_files").map { _meta, _process, _tool, r -> r })
 *     .mix(ch_methods_description.collectFile(...))
 *   MULTIQC(ch_multiqc_files.collect(), ...)
 *
 * Expected (25.10.4): MULTIQC runs after all upstream tasks complete.
 * Actual   (26.03.x-edge, cloud): collect() never fires; MULTIQC never runs.
 */

process PROC_A {
    input: val(s)
    output:
        path("${s}_a_report.txt"),                                                      emit: reports
        tuple val(task.process), val('tool_a'), val('1.0'),                             emit: versions
        tuple val('meta_a'), val(task.process), val('tool_a'), path("${s}_a_mqc.txt"), topic: 'multiqc_files'
    script: "touch ${s}_a_report.txt ${s}_a_mqc.txt"
}

process PROC_B {
    input: val(s)
    output:
        path("${s}_b_report.txt"),                                                      emit: reports
        tuple val(task.process), val('tool_b'), val('2.0'),                             emit: versions
        tuple val('meta_b'), val(task.process), val('tool_b'), path("${s}_b_mqc.txt"), topic: 'multiqc_files'
    script: "touch ${s}_b_report.txt ${s}_b_mqc.txt"
}

process PROC_C {
    input: val(s)
    output:
        path("${s}_c_report.txt"),                                                      emit: reports
        tuple val(task.process), val('tool_c'), val('3.0'),                             emit: versions
        tuple val('meta_c'), val(task.process), val('tool_c'), path("${s}_c_mqc.txt"), topic: 'multiqc_files'
    script: "touch ${s}_c_report.txt ${s}_c_mqc.txt"
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

workflow SUB_A {
    take: samples
    main: PROC_A(samples)
    emit:
        reports  = PROC_A.out.reports
        versions = PROC_A.out.versions
}

workflow SUB_B {
    take: samples
    main: PROC_B(samples)
    emit:
        reports  = PROC_B.out.reports
        versions = PROC_B.out.versions
}

workflow SUB_C {
    take: samples
    main: PROC_C(samples)
    emit:
        reports  = PROC_C.out.reports
        versions = PROC_C.out.versions
}

workflow {
    samples = channel.of('s1', 's2', 's3')

    SUB_A(samples)
    SUB_B(samples)
    SUB_C(samples)

    // Mirror sarek: sub-workflows emit versions; accumulate then mix with topic
    ch_versions = channel.empty()
    ch_versions = ch_versions.mix(SUB_A.out.versions)
    ch_versions = ch_versions.mix(SUB_B.out.versions)
    ch_versions = ch_versions.mix(SUB_C.out.versions)

    // Mirror nf-core-utils softwareVersionsToYAML() + sarek's outer collectFile:
    //   softwareVersionsToYAML returns: ch_versions.mix(topic).toList().map{...}
    //   sarek then calls .collectFile(storeDir:...) on that result
    version_yaml = ch_versions
        .mix(channel.topic('versions'))
        .toList()
        .map { versionsList ->
            versionsList.collect { t -> "${t[1]}: ${t[2]}" }.join('\n')
        }
        .collectFile(name: 'software_versions.yaml', sort: true, newLine: true)

    // Mirror sarek's reports accumulation
    reports = channel.empty()
    reports = reports.mix(SUB_A.out.reports)
    reports = reports.mix(SUB_B.out.reports)
    reports = reports.mix(SUB_C.out.reports)

    // Mirror sarek's ch_workflow_summary: value → collectFile
    ch_workflow_summary = channel.value('workflow: test\nversion: 1.0\n')
        .collectFile(name: 'workflow_summary_mqc.yaml')

    // Mirror sarek's ch_methods_description: value → collectFile
    ch_methods_description = channel.value('methods: test\n')
        .collectFile(name: 'methods_description_mqc.yaml', sort: true)

    // Mirror sarek's ch_multiqc_files construction exactly
    ch_multiqc_files = channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary)
    ch_multiqc_files = ch_multiqc_files.mix(version_yaml)
    ch_multiqc_files = ch_multiqc_files.mix(reports)
    ch_multiqc_files = ch_multiqc_files.mix(
        channel.topic('multiqc_files').map { _meta, _process, _tool, r -> r }
    )
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description)

    MULTIQC(
        ch_multiqc_files.collect(),
        'multiqc_config.yaml',
    )
}
