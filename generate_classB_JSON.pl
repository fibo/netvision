#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classC;
use dataDir;
use jsonFile;

my $classB_subnet = $ARGV[0];

my $data_dir = &dataDir::forClassB($classB_subnet);

&dataDir::create($data_dir);

my @classC_subnets;

# Skip 0 and 255 addresses.
for my $c ( 1 .. 254 ) {
  push @classC_subnets, $classB_subnet . ".$c";
}

for my $subnet (@classC_subnets) {
  my $json_filepath = &jsonFile::forClassC($subnet);

  my $json_file_exists = -e $json_filepath;

  if ($json_file_exists) {
      say $json_filepath;
  } else {
      classC::generateDataFileFor($subnet);
  }
}

__END__
my $ping_response = &classC::ping($subnet);

my $subnet_data = { subnet => $subnet, ping => $ping_response };

jsonFile::write($json_filepath, $subnet_data);
