package jsonFile;
use strict;
use warnings;
use v5.12;

use JSON::PP;

use dataDir;

sub forClassB {
    my $subnet = shift;

    my $target_dir = &dataDir::forClassB($subnet);

    my $json_filepath = "$target_dir/$subnet.json";

    return $json_filepath;
}

sub forClassC {
    my $subnet = shift;

    my $target_dir = &dataDir::forClassC($subnet);

    my $json_filepath = "$target_dir/$subnet.json";

    return $json_filepath;
}

sub read {
    my ( $target_file ) = @_;

    open my $fh, '<:encoding(UTF-8)', $target_file;
    local $/;

    my $subnet_data = decode_json(<$fh>);
    close $fh;

    return $subnet_data;
}

sub write {
    my ( $target_file, $subnet_data ) = @_;

    binmode STDOUT, ':utf8';
    open my $fh, '>', $target_file;
    print $fh encode_json($subnet_data);
    close $fh;
}

1;
