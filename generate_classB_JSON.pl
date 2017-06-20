#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use File::Find ();

use lib 'lib';

use classB;
use dataDir;
use jsonFile;
use S3;

&S3::envDefinedOrExit;

my $overwrite = ${ENV}{OVERWRITE};

my $classB_subnet = $ARGV[0] || die "missing argument\n";

my $aggregated_json_file = &jsonFile::forClassB($classB_subnet);

# Exit if class B data file already exists locally.
if ( -e $aggregated_json_file and not $overwrite ) {
    die "File $aggregated_json_file already exists\n";
}

# Exit if class B data file already exists on S3.
if ( &S3::exists($aggregated_json_file) and not $overwrite ) {
    die "File s3://ip-v4.space/$aggregated_json_file already exists\n";
}

# Scan subnet.
&classB::generateDataFileFor($classB_subnet);

# Upload file to S3.
&S3::upload($aggregated_json_file);

# Clean up data dir
my $data_dir = &dataDir::forClassB($classB_subnet);
File::Find::find( { wanted => \&cleanup }, $data_dir );

sub cleanup { unlink }
