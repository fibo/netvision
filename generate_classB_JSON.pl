#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classC;
use dataDir;
use jsonFile;
use S3;

&S3::envDefinedOrExit;

my $classB_subnet = $ARGV[0] || die "missing argument\n";

my $aggregated_json_file = &jsonFile::forClassB($classB_subnet);

# Exit if class B data file already exists on S3.
if ( &S3::exists($aggregated_json_file) ) {
    die "File s3://ip-v4.space/$aggregated_json_file already exists\n";
} else {
    # Scan subnet.
    &classB::generateDataFileFor($classB_subnet);

    # Upload file to S3.
    &S3::upload($aggregated_json_file);
}

