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
    // First API call - Create Data Link
    def dataLinkBody = [
        name: "fastqc-results",
        description: "FastQC results data link",
        type: "bucket",
        provider: "aws",
        resourceRef: params.outdir,
        publicAccessible: false,
        credentialsId: "iiOV1dcrVkeBj551xRmWM"
    ]

    def dataLinkJson = new groovy.json.JsonBuilder(dataLinkBody).toString()
    
    // Make the first API call to create data link
    def dataLinkUrl = new URL('https://cloud.seqera.io/api/data-links')
    def dataLinkFinalUrl = new URL(dataLinkUrl.toString() + "?workspaceId=${params.workspaceId}")
    def dataLinkResponse = dataLinkFinalUrl.openConnection() as HttpURLConnection
    
    def dataLinkId = null
    
    dataLinkResponse.with {
        requestMethod = 'POST'
        doOutput = true
        setRequestProperty('Content-Type', 'application/json')
        setRequestProperty('Authorization', "Bearer ${System.getenv('TOWER_ACCESS_TOKEN')}")
        
        outputStream.withWriter { writer ->
            writer << dataLinkJson
        }
        
        // Handle the response
        if (responseCode == 200 || responseCode == 201) {
            def responseText = inputStream.text
            def responseJson = new groovy.json.JsonSlurper().parseText(responseText)
            dataLinkId = responseJson.id  // Get the ID instead of name
            println "Successfully created data link: ${responseText}"
        } else {
            println "Failed to create data link. Status code: ${responseCode}"
            println "Error message: ${errorStream.text}"
            return  // Exit if data link creation fails
        }
    }

    // Only proceed with Studio creation if we have a data link ID
    if (dataLinkId) {
        // Second API call - Create Studio
        def studioBody = [
            name: "fastqc-results",
            description: "FastQC results studio",
            dataStudioToolUrl: "public.cr.seqera.io/platform/data-studio-jupyter:4.2.5-0.7",
            computeEnvId: params.computeEnvId,
            configuration: [
                gpu: 0,
                cpu: 2,
                memory: 2048,
                mountData: [dataLinkId],  // Use the ID instead of name
            ]
        ]

        def studioJson = new groovy.json.JsonBuilder(studioBody).toString()

        def baseUrl = new URL('https://cloud.seqera.io/api/studios')
        def finalUrl = new URL(baseUrl.toString() + "?workspaceId=${params.workspaceId}")
        def response = finalUrl.openConnection() as HttpURLConnection
        
        response.with {
            requestMethod = 'POST'
            doOutput = true
            setRequestProperty('Content-Type', 'application/json')
            setRequestProperty('Authorization', "Bearer ${System.getenv('TOWER_ACCESS_TOKEN')}")
            
            outputStream.withWriter { writer ->
                writer << studioJson
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
}
