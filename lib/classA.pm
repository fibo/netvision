package classC;
use strict;
use warnings;
use v5.12;

use dataDir;
use jsonFile;

my $verbose = $ENV{VERBOSE};

sub jsonFilepathOf {
    my $subnet = shift;

    my $data_dir = &dataDir::forClassA($subnet);

    my $json_filepath = "$data_dir/$subnet.json";

    return $json_filepath;
}

1;
