#!/bin/env perl
use strict;
use warnings;
use FindBin;
use File::Spec;
use DBI;
use Teng::Schema::Dumper;

my $conf = do File::Spec->catdir($FindBin::Bin, '..', 'config', 'block_hash.development.conf') 
    or die "config file not found. $!";

my $db = $conf->{db};
my $dbh = DBI->connect(
    $db->{connect_info},
    $db->{user},
    $db->{password},
    $db->{option},
) or die "db connection error. $!";

my $schema = Teng::Schema::Dumper->dump(
    dbh => $dbh, 
    namespace => 'BlockHash::DB',
    inflate => +{ tweet => q|
        inflate qr/.+_json/ => sub {
            use JSON;
            use Encode;
            return decode_json(encode_utf8(shift));
        };
        inflate qr/.+_at/ => sub {
            use Time::Piece;
            use Time::Seconds;
            my $t = Time::Piece->strptime(shift, "%Y-%m-%d %H:%M:%S");
            return $t + 9*60*60;
        };
    |},
);

my $dest = File::Spec->catfile($FindBin::Bin, '..', 'lib', 'BlockHash', 'DB', 'Schema.pm');
open my $fh, '>', $dest or die "cannot open file '$dest': $!";
print {$fh} $schema;
close;
