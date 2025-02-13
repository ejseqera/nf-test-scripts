#!/usr/bin/env nextflow

// Create a simple process that generates a text file

process FASTQC {
    tag "FASTQC on $sample_id"
    conda 'bioconda::fastqc=0.12.1'
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_${sample_id}_logs"

    script:
    """
    mkdir -p fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs ${reads}
    """
}

workflow {
    read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 

    FASTQC(read_pairs_ch)
}

workflow.onComplete {
    // Prepare the API request body
    def requestBody = [
        name: "test-api-studios",
        description: "Esha is testing stuff",
        dataStudioToolUrl: "public.cr.seqera.io/platform/data-studio-jupyter:4.2.5-0.7",
        computeEnvId: params.computeEnvId,
        configuration: [
            gpu: 0,
            cpu: 2,
            memory: 2048,
            mountData: [params.outdir],
        ]
    ]

    // Convert the request body to JSON
    def jsonBody = new groovy.json.JsonBuilder(requestBody).toString()

    // Make the API call using Nextflow's HTTP client
    def baseUrl = new URL('https://cloud.seqera.io/api/studios')
    def finalUrl = new URL(baseUrl.toString() + "?workspaceId=${params.workspaceId}")
    def response = finalUrl.openConnection() as HttpURLConnection
    
    response.with {
        requestMethod = 'POST'
        doOutput = true
        setRequestProperty('Content-Type', 'application/json')
        setRequestProperty('Authorization', "Bearer ${System.getenv('TOWER_ACCESS_TOKEN')}")
        
        outputStream.withWriter { writer ->
            writer << jsonBody
        }
        
        // Handle the response
        if (responseCode == 200 || responseCode == 201) {
            println "Successfully created studio: ${inputStream.text}"
        } else {
            println "Failed to create studio. Status code: ${responseCode}"
            println "Error message: ${errorStream.text}"
        }
    }
}
