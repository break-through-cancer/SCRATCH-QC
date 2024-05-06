process CELLRANGER_VDJ {

    tag "Running VDJ on ${sample}"
    label 'process_high'

    container "oandrefonseca/scaligners:main"
    publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true

    input:
        tuple val(sample), path(reads)
        path(reference)

    output:
        tuple val(sample), path("tcr/${sample}/outs/*"), emit: outs

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
            cellranger_renaming.py "${sample}" . 

            cellranger \\
                vdj \\
                --id="${sample}" \\
                --fastqs=. \\
                --reference="${reference.name}" \\
                --localcores=${task.cpus} \\
                --localmem=${task.memory.toGiga()}

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cellranger: \$(echo \$( cellranger --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*\\).*\$/\\1/' )
                reference: ${reference.name}
            END_VERSIONS
        """

    stub:
        """
            cellranger_renaming.py "${sample}" .

            mkdir -p tcr/${sample}/outs/filtered_feature_bc_matrix

            touch tcr/${sample}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz  
            touch tcr/${sample}/outs/filtered_feature_bc_matrix/features.tsv.gz
            touch tcr/${sample}/outs/filtered_feature_bc_matrix/matrix.mtx.gz
            touch tcr/${sample}/outs/metrics_summary.csv
            
            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cellranger: \$(echo \$( cellranger --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*\\).*\$/\\1/' )
                referemce: ${reference.name}
            END_VERSIONS
        """
}