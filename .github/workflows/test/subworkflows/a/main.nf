include { PROCESS_A } from '../../modules/a/main.nf'

workflow SUBWORKFLOW_A {
    PROCESS_A()
}