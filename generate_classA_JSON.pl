#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classA;
use classB;
use jsonFile;
use S3;

my $verbose = $ENV{VERBOSE};

&S3::envDefinedOrExit;

my $classA_subnet = $ARGV[0] || die "missing argument\n";

if ( ( $classA_subnet < 0 ) or ( $classA_subnet >= 255 ) ) {
    die "Invalid IPv4 class A subnet\n";
}

my $aggregated_json_file = &jsonFile::forClassA($classA_subnet);

my @subnet_data = [];

my @aggregated_json_data;

for my $b ( 0 .. 255 ) {
    my $classB_subnet = "$classA_subnet.$b";
    my @classB_ping;
    my $at_least_one_classC_ping_is_not_zero = 0;

    my $json_filepath = &jsonFile::forClassB($classB_subnet);

    my $json_file_does_not_exist;

    $json_file_does_not_exist = not -e $json_filepath;

    # Try to download data file from S3, if any.
    if ($json_file_does_not_exist) {
        if ( &S3::exists($json_filepath) ) {
            &S3::download($json_filepath);
        }
    }

    if ($json_file_does_not_exist) {
        push @classB_ping, -1;
        say "No data for $classB_subnet" if $verbose;
        next;
    }
    else {
        my $subnetB_data = jsonFile::read($json_filepath);

        for my $subnetC_data ( @{$subnetB_data} ) {
            my $subnetC = $subnetC_data->{subnet};
            my $pingC   = $subnetC_data->{ping};

            my $resultC;

            if ( $pingC eq 0 ) {
                $resultC = 0;
            }
            else {
                $at_least_one_classC_ping_is_not_zero = 1;
                $resultC                              = 1;
            }

            push @classB_ping, $resultC;
        }

        if ($at_least_one_classC_ping_is_not_zero) {
            push @subnet_data,
              {
                ping   => \@classB_ping,
                subnet => $classB_subnet
              };
        }
        else {
            push @subnet_data,
              {
                ping   => 0,
                subnet => $classB_subnet
              };
        }

        say "$classB_subnet" if $verbose;
    }
}

&jsonFile::write( $aggregated_json_file, \@subnet_data );

# Upload file to S3.
&S3::upload($aggregated_json_file);
