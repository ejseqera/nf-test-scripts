
workflow {
    Channel.fromPath("s3://scidev-eu-west-1/esha/many_files_test/dummy_file_*.txt").collect()
}
