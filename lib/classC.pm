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

my $overwrite = $ENV{OVERWRITE};

sub generateDataFileFor {
    my $subnet = shift;

    my $json_filepath = &jsonFile::forClassC($subnet);

    # Return if file already exists locally.
    if ( -e $json_filepath and not $overwrite ) {
      say "File $json_filepath already exists" if $verbose;
      return;
    }

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

sub isReserved {
    my $subnet = shift;

    my ($a, $b, $c) = &parse($subnet);

    return 1 if ($a == '0');
    return 1 if ($a == '10');
    return 1 if ($a == '127');
    return 1 if (($a == '169') && ($b == '254'));
    return 1 if (($a == '172') && ($b == '16'));
    return 1 if (($a == '172') && ($b == '17'));
    return 1 if (($a == '172') && ($b == '18'));
    return 1 if (($a == '172') && ($b == '19'));
    return 1 if (($a == '172') && ($b == '20'));
    return 1 if (($a == '172') && ($b == '21'));
    return 1 if (($a == '172') && ($b == '22'));
    return 1 if (($a == '172') && ($b == '23'));
    return 1 if (($a == '172') && ($b == '24'));
    return 1 if (($a == '172') && ($b == '25'));
    return 1 if (($a == '172') && ($b == '26'));
    return 1 if (($a == '172') && ($b == '27'));
    return 1 if (($a == '172') && ($b == '28'));
    return 1 if (($a == '172') && ($b == '29'));
    return 1 if (($a == '172') && ($b == '30'));
    return 1 if (($a == '172') && ($b == '31'));
    return 1 if (($a == '192') && ($b == '0') && ($c == '0'));
    return 1 if (($a == '192') && ($b == '0') && ($c == '2'));
    return 1 if (($a == '192') && ($b == '88') && ($c == '99'));
    return 1 if (($a == '192') && ($b == '168'));
    return 1 if (($a == '198') && ($b == '18'));
    return 1 if (($a == '198') && ($b == '19'));
    return 1 if (($a == '198') && ($b == '51') && ($c == '100'));
    return 1 if (($a == '203') && ($b == '0') && ($c == '13'));
    return 1 if ($a == '224');
    return 1 if ($a == '225');
    return 1 if ($a == '226');
    return 1 if ($a == '227');
    return 1 if ($a == '228');
    return 1 if ($a == '229');
    return 1 if ($a == '230');
    return 1 if ($a == '231');
    return 1 if ($a == '232');
    return 1 if ($a == '233');
    return 1 if ($a == '234');
    return 1 if ($a == '235');
    return 1 if ($a == '236');
    return 1 if ($a == '237');
    return 1 if ($a == '238');
    return 1 if ($a == '239');
    return 1 if ($a == '240');

    return 0;
}

sub ping {
    my $subnet = shift;

    if (&isReserved($subnet)) {
        say "Subnet $subnet.* is reserved" if $verbose;
        return 0
    }

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

            say "Address $address does not respond" if $verbose;

            push @response, 0;
        }
    }

    $p->close();

    my $end = time;

    my $sec = $end - $start;

    say "Subnet $subnet pinged in $sec seconds" if $timing;

    # Return a single 0 if no alive host was found.
    return 0 if $no_alive_host_found;

    # Return a single 1 if all hosts was found alive.
    return 1 if $all_hosts_are_alive;

    # Otherwise return the response array, will require more disc space.
    return \@response;
}

1;
