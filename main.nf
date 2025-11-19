#!/usr/bin/env nextflow

process GPU_TEST {
    container 'nvidia/cuda:12.2.0-base-ubuntu22.04'
    debug true
    
    output:
    stdout

    script:
    """
    echo "Testing GPU access..."
    nvidia-smi
    echo "GPU test completed successfully!"
    """
}

workflow {
    GPU_TEST | view
}
