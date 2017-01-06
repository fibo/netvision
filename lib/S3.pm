package S3;
use strict;
use warnings;
use v5.12;

my $verbose = $ENV{VERBOSE};

# Check that aws cli environment variable are defined.
sub envDefinedOrExit {
    defined $ENV{AWS_DEFAULT_REGION}
    and $ENV{AWS_DEFAULT_REGION} ne 'us-east-1'
    and defined $ENV{AWS_SECRET_ACCESS_KEY}
    and defined $ENV{AWS_ACCESS_KEY_ID}
    or die "aws cli environment variables not defined\n";
}

sub download {
    my $file_path = shift || die "missing parameter";

    say "Download $file_path" if $verbose;

    `aws s3 cp s3://ip-v4.space/$file_path ${file_path}`;
}

sub exists {
    my $file_path = shift || die "missing parameter";
    return `aws s3 ls s3://ip-v4.space/$file_path`;
}

sub upload {
    my $file_path = shift || die "missing parameter";

    say "Upload $file_path" if $verbose;

    `aws s3 cp ${file_path} s3://ip-v4.space/$file_path`;
}

1;
