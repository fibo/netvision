#!/usr/bin/perl
use strict;
use warnings;

use Net::Ping;
use GD;

my $net = $ARGV[0];
my %nv;
my $timeout = 1;

&Main;

sub Main {
    &checkSubNet;
    &scan;
    &render;
}

sub checkSubNet {
    $net =~ /\d{1,3}\.\d{1,3}/ or die "aaaaaaarrrrrrrrghhhhhhhh  ( asd )";
}

sub render {
    my $im = new GD::Image( 256, 256 );

    # allocate some colors
    my $white = $im->colorAllocate( 255, 255, 255 );
    my $black = $im->colorAllocate( 0,   0,   0 );
    my $red   = $im->colorAllocate( 255, 0,   0 );
    my $blue  = $im->colorAllocate( 0,   0,   255 );

    # make the background transparent and interlaced
    $im->transparent($white);
    $im->interlaced('true');

    for my $x ( 0 .. 255 ) {
        for my $y ( 0 .. 255 ) {
            my $ip = $net . "." . $x . "." . $y;

            if ( $nv{$ip} ) {
                $im->setPixel( $x, $y, $red );
            }
            else {
                $im->setPixel( $x, $y, $white );
            }
        }
    }

    # make sure we are writing to a binary stream
    binmode STDOUT;

    open OUT, "> $net.png";
    print OUT $im->png;
    close OUT;
}

sub scan {
    my $p = Net::Ping->new( "tcp", $timeout );
    for my $host (&getTargetHosts) {
        print ".";
        if ( $p->ping($host) ) {
            $nv{$host} = 1;
            print "\n$host is alive\n";
        }
        else {
            $nv{$host} = 0;
        }
    }
    $p->close();
}

sub getTargetHosts {
    my @out;
    for my $c ( 0 .. 255 ) {
        for my $d ( 0 .. 255 ) {
            push @out, $net . "." . $c . "." . $d;
        }
    }
    return @out;
}
