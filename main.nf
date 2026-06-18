#!/usr/bin/env nextflow

process GPU_CHECK {
    debug true

    output:
    stdout

    script:
    """
    echo "=== Host GPU check ==="
    nvidia-smi || echo "nvidia-smi NOT FOUND"
    echo ""
    echo "=== NVIDIA binaries in /usr/bin ==="
    ls /usr/bin/nvidia* 2>/dev/null || echo "NO NVIDIA BINARIES in /usr/bin"
    echo ""
    echo "=== NVIDIA libs ==="
    ls /usr/lib/x86_64-linux-gnu/libnvidia* 2>/dev/null || echo "NO NVIDIA LIBS"
    echo ""
    echo "=== /proc/driver/nvidia ==="
    ls /proc/driver/nvidia/ 2>/dev/null || echo "/proc/driver/nvidia NOT PRESENT"
    echo ""
    echo "=== AMI identity ==="
    curl -sf http://169.254.169.254/latest/meta-data/ami-id || echo "AMI metadata unavailable"
    echo ""
    echo "=== Instance type ==="
    curl -sf http://169.254.169.254/latest/meta-data/instance-type || echo "Instance type unavailable"
    """
}

workflow {
    GPU_CHECK | view
}
