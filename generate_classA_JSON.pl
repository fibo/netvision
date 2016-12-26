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

my $subnet_data = { subnet => $classA_subnet, ping => [] };

my @aggregated_json_data;

for my $b ( 0 .. 255 ) {
    my $classB_subnet = "$classA_subnet.$b";

    my $resultB = 0;

    my $json_filepath = &jsonFile::forClassB($classB_subnet);

    my $json_file_does_not_exist = not -e $json_filepath;

    if ($json_file_does_not_exist) {
        if ( &S3::exists($json_filepath) ) {
            &S3::download($json_filepath);
        }
        else {
            # Generate missing data file.
            &classB::generateDataFileFor($classB_subnet);

            # Upload it to S3.
            &S3::upload($json_filepath);
        }
    }

    my $subnetB_data = jsonFile::read($json_filepath);

    for my $subnetC_data ( @{$subnetB_data} ) {
        my $subnetC = $subnetC_data->{subnet};
        my $pingC   = $subnetC_data->{ping};

        my $resultC;

        # At this level, count all 0 and 1 and output a single 0 or 1
        # depending on how many of them are found.
        if ( $pingC eq 0 ) {
            $resultC = 0;
        }
        elsif ( $pingC eq 1 ) {
            $resultC = 1;
        }
        else {
            $resultC += $_ for ( @{ $subnetC_data->{ping} } );

            if ( $resultC > 128 ) {

                # There are more 0 than 1.
                $resultC = 0;
            }
            else {
                $resultC = 1;
            }
        }

        # Taking advantage of the analogy between colors and IPs,
        # I mean that there are exactly 255 in every subnet and
        # rgb colors range from 0 to 255, it is worth to write a sum,
        # so if a cell get a 0 it will be white, the more it reaches 255
        # the more color it will have. It will be a nice effect.
        $resultB += $resultC;
    }

    say "$classB_subnet $resultB" if $verbose;

    # Add result, force number context otherwise JSON will be
    # something like
    #
    # {"ping":["204","201","108" ...]}
    $subnet_data->{ping}->[$b] = 0 + $resultB;
}

&jsonFile::write( $aggregated_json_file, $subnet_data );

# Upload file to S3.
&S3::upload($aggregated_json_file);
