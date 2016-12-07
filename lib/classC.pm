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
my $timing  = $ENV{TIMING};
$timing = 1 if $verbose;

sub generateDataFileFor {
    my $subnet = shift;

    my $json_filepath = &jsonFile::forClassC($subnet);

    my $data_dir = &dataDir::forClassC($subnet);

    &dataDir::create($data_dir);

    my $ping_response = &ping($subnet);

    my $subnet_data = { subnet => $subnet, ping => $ping_response };

    jsonFile::write( $json_filepath, $subnet_data );
}

sub parse {
    my $subnet = shift;

    $subnet =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      or die "Invalid IPv4 class C subnet $subnet\n";

    my $a = $1;
    my $b = $2;
    my $c = $3;

    return ( $a, $b, $c );
}

sub ping {
    my $subnet = shift;

    my $start = time;

    my @response;

    my $p = Net::Ping->new( 'icmp', $timeout );

    say "ICMP ping of subnet $subnet.* with $timeout sec. timeout" if $verbose;

    my @addresses;

    # Skip 0 and 255 addresses.
    for my $d ( 1 .. 254 ) {
        push @addresses, "$subnet.$d";
    }

    my $no_alive_host_found = 1;
    my $all_hosts_are_alive = 1;

    for my $address (@addresses) {
        if ( $p->ping($address) ) {
            $no_alive_host_found = 0;

            push @response, 1;

            say "Address $address is alive" if $verbose;
        }
        else {
            $all_hosts_are_alive = 0;
            push @response, 0;
        }
    }

    $p->close();

    my $end = time;

    my $sec = $end - $start;

    say "Subnet $subnet pinged in $sec seconds." if $timing;

    return 0 if $no_alive_host_found;

    return 1 if $all_hosts_are_alive;

    return \@response;
}

1;
