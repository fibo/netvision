#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classB;
use jsonFile;
use S3;

my $verbose = $ENV{VERBOSE};

&S3::envDefinedOrExit;

my $classA_subnet = $ARGV[0] || die "missing argument\n";

if (($classA_subnet < 0) or ($classA_subnet >= 255)) {
    die "Invalid IPv4 class A subnet\n";
}

for my $b ( 0 .. 255 ) {
    my $classB_subnet = "$classA_subnet.$b";

    my $json_filepath = &jsonFile::forClassB($classB_subnet);

    my $json_file_does_not_exist = not -e $json_filepath;

    if ($json_file_does_not_exist) {
        if ( &S3::exists($json_filepath) ) {
            &S3::download($json_filepath);
        } else {
            # Generate missing data file.
            &classB::generateDataFileFor($classB_subnet);

            # Upload it to S3.
            &S3::upload($aggregated_json_file);
        }
    }
}
