#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classA;
use S3;

my $verbose = $ENV{VERBOSE};

&S3::envDefinedOrExit;

my $classA_subnet = $ARGV[0] || die "missing argument\n";

if ( ( $classA_subnet < 0 ) or ( $classA_subnet >= 255 ) ) {
    die "Invalid IPv4 class A subnet\n";
}

my $aggregated_json_file = &jsonFile::forClassA($classA_subnet);

# Scan subnet.
&classA::generateDataFileFor($classA_subnet);

# Upload file to S3.
&S3::upload($aggregated_json_file);
