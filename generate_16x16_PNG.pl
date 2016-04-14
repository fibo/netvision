#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use English;
use File::Path 'make_path';
use Net::Ping;
use GD;

$OUTPUT_AUTOFLUSH = 1;

my $verbose = $ENV{VERBOSE};

my $net = $ARGV[0];
my %response_from;
my $timeout = 1;
my ($a, $b, $c); # IPv4 first three numbers

&Main;

sub Main {
    &parseSubNet;
    &scan;
    &render;
}

sub parseSubNet {
    $net =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      or die "Invalid IPv4 class C subnet $net\n";

    $a = $1;
    $b = $2;
    $c = $3;
}

sub scan {
    my $p = Net::Ping->new( 'icmp', $timeout );

    print "icmp ping of subnet $net.* with $timeout sec. timeout\n" if $verbose;

    my @addresses;

    for my $d ( 0 .. 255 ) {
        push @addresses, $net . "." . $d;
    }

    # TODO skip 0 and 255
    # my $first = shift @addresses;
    # $response_from{$first} = 0;
    # my $last = shift @addresses;
    # $response_from{$last} = 0;

    for my $address (@addresses) {
        if ( $p->ping($address) ) {
            $response_from{$address} = 1;

            print "\n$address is alive" if $verbose;
        }
        else {
            $response_from{$address} = 0;

            print '.' if $verbose;
        }
    }

    $p->close();
}

sub render {
    my $image = new GD::Image( 16, 16 );

    my $target_dir = "data/$a/$b";
    my $target_file = "$target_dir/$net.png";
    print "\ncreating image $target_file\n";

    # allocate some colors
    my $white = $image->colorAllocate( 255, 255, 255 );
    my $black = $image->colorAllocate( 0,   0,   0 );
    my $red   = $image->colorAllocate( 255, 0,   0 );
    my $blue  = $image->colorAllocate( 0,   0,   255 );

    # make the background transparent and interlaced
    $image->transparent($white);
    $image->interlaced('true');

    for my $d ( 0 .. 255 ) {
        my $x  = $d % 16;
        my $y  = ( $d - $x ) / 16;
        my $ip = $net . "." . $d;

        if ( $response_from{$ip} ) {
            $image->setPixel( $x, $y, $red );
        }
    }

    make_path $target_dir;

    # make sure we are writing to a binary stream
    binmode STDOUT;

    open OUT, "> $target_file";
    print OUT $image->png;
    close OUT;
}

