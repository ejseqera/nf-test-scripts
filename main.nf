#!/usr/bin/env nextflow

workflow {
    Channel.fromPath(params.regular_input)
    | view { "Regular input file: $it" }
    
    Channel.fromPath(params.regex_input)
    | view { "Regex input file: $it" }
}