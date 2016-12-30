package classB;
use strict;
use warnings;
use v5.12;

use classC;
use dataDir;
use jsonFile;

my $verbose = $ENV{VERBOSE};

sub generateDataFileFor {
    my $classB_subnet = shift;

    my $aggregated_json_file = &jsonFile::forClassB($classB_subnet);

    my $data_dir = &dataDir::forClassB($classB_subnet);
    &dataDir::create($data_dir);

    my @aggregated_json_data;

    my @classC_subnets;

    for my $c ( 0 .. 255 ) {
        push @classC_subnets, $classB_subnet . ".$c";
    }

    for my $classC_subnet (@classC_subnets) {
        my $json_filepath = &jsonFile::forClassC($classC_subnet);

        my $json_file_does_not_exist = not -e $json_filepath;

        &classC::generateDataFileFor($classC_subnet);

        my $subnet_data = jsonFile::read($json_filepath);

        push @aggregated_json_data, $subnet_data;
    }

    &jsonFile::write( $aggregated_json_file, \@aggregated_json_data );
}

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

    return ( $a, $b );
}

1;
