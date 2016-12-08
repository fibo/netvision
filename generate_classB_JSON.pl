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
  and $ENV{AWS_DEFAULT_REGION} eq 'us-east-1'
  and defined $ENV{AWS_SECRET_ACCESS_KEY}
  and defined $ENV{AWS_ACCESS_KEY_ID}
  or die "aws cli environment variables not defined\n";

my $classB_subnet = $ARGV[0];

my $data_dir = &dataDir::forClassB($classB_subnet);

my @aggregated_json_data;

&dataDir::create($data_dir);

my @classC_subnets;

# Skip 0 and 255 addresses.
for my $c ( 1 .. 254 ) {
    push @classC_subnets, $classB_subnet . ".$c";
}

for my $subnet (@classC_subnets) {
    my $json_filepath = &jsonFile::forClassC($subnet);

    my $json_file_does_not_exist = not -e $json_filepath;

    # Check if class C data file already exists, otherwise create it.
    if ($json_file_does_not_exist) {
        &classC::generateDataFileFor($subnet);
    }

    my $subnet_data = jsonFile::read($json_filepath);

    push @aggregated_json_data, $subnet_data;
}

my $aggregated_json_file = &jsonFile::forClassB($classB_subnet);
&jsonFile::write($aggregated_json_file, \@aggregated_json_data);

# Upload file to S3.
`aws s3 cp ${aggregated_json_file} s3://ip-v4.space/$aggregated_json_file`;
