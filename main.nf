#!/usr/bin/env nextflow

workflow {
    Channel.fromPath(params.regular_input)
    | view { "Regular input file: $it" }
    
    Channel.fromPath(params.regex_input_1)
    | view { "Regex input 1 file: $it" }

    Channel.fromPath(params.regex_input_2)
    | view { "Regex input 2 file: $it" }
}