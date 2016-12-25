#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classC;
use dataDir;
use jsonFile;

# Check that aws cli environment variable are defined.
defined $ENV{AWS_DEFAULT_REGION}
  and $ENV{AWS_DEFAULT_REGION} ne 'us-east-1'
  and defined $ENV{AWS_SECRET_ACCESS_KEY}
  and defined $ENV{AWS_ACCESS_KEY_ID}
  or die "aws cli environment variables not defined\n";

my $classB_subnet = $ARGV[0];

my $aggregated_json_file = &jsonFile::forClassB($classB_subnet);

# Exit if class B data file already exists on S3.
my $aggregated_json_file_exists = `aws s3 ls s3://ip-v4.space/$aggregated_json_file`;

if ( $aggregated_json_file_exists ) {
    die "File s3://ip-v4.space/$aggregated_json_file already exists\n";
}

&classB::generateDataFileFor($classB_subnet);

# Upload file to S3.
`aws s3 cp ${aggregated_json_file} s3://ip-v4.space/$aggregated_json_file`;
