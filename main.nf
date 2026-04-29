#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


// ─── processes ──────────────────────────────────────────────────────────────

process runRecx {
    label "recx"
    publishDir "${params.out_dir}", mode: 'copy', pattern: "recx.txt"
    cpus 1
    memory "1 GB"
    output:
        path "recx.txt"
    script:
    """
    recx.sh > recx.txt
    """
}


// ─── workflow ────────────────────────────────────────────────────────────────

workflow {
    if (params.help) {
        log.info """
        testWorkflow — skeleton test workflow
        ======================================
        Usage:
            nextflow run main.nf [options]

        Options:
            --out_dir   Output directory [default: output]
            --help      Show this help message
            --version   Show workflow version
        """.stripIndent()
        exit 0
    }

    if (params.version) {
        log.info "${workflow.manifest.version}"
        exit 0
    }

    runRecx()
}
