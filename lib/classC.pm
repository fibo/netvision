package classC;
use strict;
use warnings;
use v5.12;

use English;
use Net::Ping;

use dataDir;
use jsonFile;

$OUTPUT_AUTOFLUSH = 1;

my $timeout = 1;
my $verbose = $ENV{VERBOSE};

sub generateDataFileFor {
    my $subnet = shift;

    my $json_filepath = &jsonFile::forClassC($subnet);

    my $data_dir = &dataDir::forClassC($subnet);

    &dataDir::create($data_dir);

    my $ping_response = &ping($subnet);

    my $subnet_data = { subnet => $subnet, ping => $ping_response };

    jsonFile::write($json_filepath, $subnet_data);
}

sub parse {
    my $subnet = shift;

    $subnet =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      or die "Invalid IPv4 class C subnet $subnet\n";

    my $a = $1;
    my $b = $2;
    my $c = $3;

    return ($a, $b, $c);
}

sub ping {
    my $subnet = shift;

    my $start = time;

    my @response;

    my $p = Net::Ping->new( 'icmp', $timeout );

    print "icmp ping of subnet $subnet.* with $timeout sec. timeout\n" if $verbose;

    my @addresses;

    # Skip 0 and 255 addresses.
    for my $d ( 1 .. 254 ) {
        push @addresses, "$subnet.$d";
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

    my $end = time;

    my $sec = $end - $start;

    print "\nSubnet $subnet ping in $sec seconds.\n" if $verbose;

    return \@response
}

1;
