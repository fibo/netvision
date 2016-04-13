#!/usr/bin/perl
use v5.12;
use strict;
use warnings;

use File::Path 'make_path';
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
    $net =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}$/
      or die "aaaaaaarrrrrrrrghhhhhhhh  ( asd )";
}

sub render {
    my $im = new GD::Image( 16, 16 );

    # allocate some colors
    my $white = $im->colorAllocate( 255, 255, 255 );
    my $black = $im->colorAllocate( 0,   0,   0 );
    my $red   = $im->colorAllocate( 255, 0,   0 );
    my $blue  = $im->colorAllocate( 0,   0,   255 );

    # make the background transparent and interlaced
    $im->transparent($white);
    $im->interlaced('true');

    for my $d ( 0 .. 255 ) {
      my $x = $d % 16;
      my $y = ($d - $x)/16;
            my $ip = $net . "." . $d;

               if ( $nv{$ip} ) {
                $im->setPixel( $x, $y, $red );
            }
            else {
                $im->setPixel( $x, $y, $white );
            }
        }

    # make sure we are writing to a binary stream
    binmode STDOUT;

    my $target_dir='.';
    my $IPV4SPACE_PUBLIC_DIR=$ENV{IPV4SPACE_PUBLIC_DIR};
    if(defined($IPV4SPACE_PUBLIC_DIR)){
      my $sub_dirs=$net;
      $sub_dirs=~s!\.!/!g;
      $target_dir="$IPV4SPACE_PUBLIC_DIR/$sub_dirs";
      make_path $target_dir;
    }
    open OUT, "> $target_dir/$net.png";
    print OUT $im->png;
    close OUT;
}

sub scan {
    my $p = Net::Ping->new( 'icmp', $timeout );
    for my $host (&getTargetHosts) {
        if ( $p->ping($host) ) {
            $nv{$host} = 1;
            #print "\n$host is alive\n";
        }
        else {
            $nv{$host} = 0;
        }
    }
    $p->close();
}

sub getTargetHosts {
    my @out;
    for my $d ( 0 .. 255 ) {
        push @out, $net . "." . $d;
    }
    return @out;
}
