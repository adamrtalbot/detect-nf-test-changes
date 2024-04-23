include { PROCESS_A } from '../../modules/a/main.nf'
include { PROCESS_C } from '../../modules/c/main.nf'

workflow SUBWORKFLOW_A {
    PROCESS_A()
    PROCESS_C()
}