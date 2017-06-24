#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classA;
use jsonFile;
use S3;

my $verbose = $ENV{VERBOSE};

&S3::envDefinedOrExit;

my @master_tile_data;

my $aggregated_json_file = 'data/master_tile.json';

for my $classA_subnet ( 0 .. 255 ) {
    my @classA_ping;
    my $at_least_one_classB_ping_is_not_zero = 0;

    my $json_filepath = &jsonFile::forClassA($classA_subnet);

    my $json_file_does_not_exist;

    $json_file_does_not_exist = not -e $json_filepath;

    # Try to download data file from S3, if any.
    if ($json_file_does_not_exist) {
        if ( &S3::exists($json_filepath) ) {
            &S3::download($json_filepath);
        }
    }

    $json_file_does_not_exist = not -e $json_filepath;

    if ($json_file_does_not_exist) {
        &classA::generateDataFileFor($classA_subnet);
    }

    my $subnetA_data = jsonFile::read($json_filepath);

    for my $subnetB_data ( @{$subnetA_data} ) {
        my $pingB = $subnetB_data->{ping};

        my $resultB;

        if ( ( $pingB eq -1 ) || ( $pingB eq 0 ) ) {
            $resultB = 0;
        }
        else {
            $at_least_one_classB_ping_is_not_zero = 1;
            $resultB                              = 1;
        }

        push @classA_ping, $resultB;
    }

    if ($at_least_one_classB_ping_is_not_zero) {
        push @master_tile_data,
          {
            ping   => \@classA_ping,
            subnet => $classA_subnet
          };
    }
    else {
        push @master_tile_data,
          {
            ping   => 0,
            subnet => $classA_subnet
          };
    }

    say "$classA_subnet" if $verbose;
}

&jsonFile::write( $aggregated_json_file, \@master_tile_data );

# Upload file to S3.
&S3::upload($aggregated_json_file);
