package classC;
use strict;
use warnings;
use v5.12;

use English;
use Net::Ping;

$OUTPUT_AUTOFLUSH = 1;

my $timeout = 1;
my $verbose = $ENV{VERBOSE};

sub parse {
    my $subnet = shift;

    $subnet =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      or die "Invalid IPv4 class C subnet $subnet\n";

    my $a = $1;
    my $b = $2;
    my $c = $3;

    return ($a, $b, $c);
}

sub ping () {
    my $subnet = shift;

    my @response;

    my $p = Net::Ping->new( 'icmp', $timeout );

    print "icmp ping of subnet $subnet.* with $timeout sec. timeout\n" if $verbose;

    my @addresses;

    for my $d ( 1 .. 254 ) {
        push @addresses, $subnet . "." . $d;
    }

    for my $address (@addresses) {
        if ( $p->ping($address) ) {
            push @response, 1;

            print "\n$address is alive" if $verbose;
        }
        else {
            push @response, 0;

            print '.' if $verbose;
        }
    }

    $p->close();

    return \@response
}

1;
