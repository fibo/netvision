package dataDir;
use strict;
use warnings;
use v5.12;

use File::Path 'make_path';

use classB;
use classC;

sub forClassA {
    my $a = shift;

    return "data/$a";
}

sub forClassB {
    my $subnet = shift;

    my ($a) = classB::parse($subnet);

    return "data/$a";
}

sub forClassC {
    my $subnet = shift;

    my ( $a, $b ) = &classC::parse($subnet);

    return "data/$a/$b";
}

sub create {
    my $subdir = shift;

    my $subdir_does_not_exists = not -d $subdir;

    if ($subdir_does_not_exists) {
        make_path $subdir or die "Cannot create dir $subdir";
    }
}

1;
