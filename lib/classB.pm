package classB;
use strict;
use warnings;
use v5.12;

use dataDir;

sub jsonFilepathOf {
    my $subnet = shift;

    my $data_dir = &dataDir::forClassC($subnet);

    my $json_filepath = "$data_dir/$subnet.json";

    return $json_filepath;
}

sub parse {
    my $subnet = shift;

    $subnet =~ /^(\d{1,3})\.(\d{1,3})$/
      or die "Invalid IPv4 class B subnet $subnet\n";

    my $a = $1;
    my $b = $2;

    return ($a, $b);
}

1;
