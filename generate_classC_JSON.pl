#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use English;
use File::Path 'make_path';
use JSON::PP;

use lib 'lib';

use classC;

$OUTPUT_AUTOFLUSH = 1;

my $subnet = $ARGV[0];

my ($a, $b, $c) = &classC::parse($subnet);

my $target_dir = "data/$a/$b";
make_path $target_dir;

my $target_file = "$target_dir/$subnet.json";

my $ping_response = &classC::ping($subnet);

my $subnet_data = { subnet => $subnet, ping => $ping_response };

binmode STDOUT, ':utf8';
open my $fh, '>', $target_file;
print $fh encode_json( $subnet_data );
close $fh;
