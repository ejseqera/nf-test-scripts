// Test whether a pd-standard attached disk is cleaned up after Batch job completes.
// After this runs, check GCP Console > Compute Engine > Disks for any orphaned disks.

process PD_DISK_TEST {
    disk 10.GB, type: 'pd-standard'

    output:
        path 'disk_info.txt'

    """
    echo "Hostname: \$(hostname)" > disk_info.txt
    echo "Date: \$(date)" >> disk_info.txt
    df -h /tmp >> disk_info.txt
    lsblk >> disk_info.txt
    """
}

workflow {
    PD_DISK_TEST()
    PD_DISK_TEST.out.view { "Disk info:\n\${it.text}" }
}
