nextflow.enable.dsl=2

include { sayHello } from "./hello/main.nf"

workflow {
    greetings_ch = Channel.of("Hola1", "Hola2", "Hola3")
    sayHello(greetings_ch)
}
