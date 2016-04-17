#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classC;
use dataDir;
use jsonFile;

my $classB_subnet = $ARGV[0];

my $data_dir = &dataDir::forClassB($classB_subnet);

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

    # TODO open all json files and aggregate them
}
