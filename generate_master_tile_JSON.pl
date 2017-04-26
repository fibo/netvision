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

my $master_tile_data = { ping => [] };

my @aggregated_json_data;
my $aggregated_json_file = 'data/master_tile.json';

for my $a ( 0 .. 255 ) {
    my $resultA = 0;

    my $json_filepath = &jsonFile::forClassA($a);

    my $json_file_does_not_exist = not -e $json_filepath;

    if ($json_file_does_not_exist) {
       if ( &S3::exists($json_filepath) ) {
           &S3::download($json_filepath);
       }
       else {
           # File is missing, do not block master tile creation.
           $master_tile_data->{ping}->[$a] = 0;
       }
    } else {
        my $subnetA_data = jsonFile::read($json_filepath);
        my $sum = 0;

        for my $count (@{$subnetA_data->{ping}}) {
            $sum += $count;
        }

        my $average = int($sum / 255);
        $master_tile_data->{ping}->[$a] = $average;
    }
}

&jsonFile::write( $aggregated_json_file, $master_tile_data );

# Upload file to S3.
&S3::upload($aggregated_json_file);
