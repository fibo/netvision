#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use lib 'lib';

use classC;

my $subnet = $ARGV[0];

classC::generateDataFileFor($subnet);
