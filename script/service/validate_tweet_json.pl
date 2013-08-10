#!/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use Encode;
use DBI;
use JSON;

use Data::Dumper;

our $self;
setup();
validate();
exit;

#--------------------------------------------------------------------------------------------
sub setup {
    unless (defined $self->{config}) {
        my $conf = do File::Spec->catdir($FindBin::Bin, 
            qw/.. .. config block_hash.development.conf/)
            or die "config file not found. $!";
        $self->{config} = $conf;
    }
    
    unless (defined $self->{dbh}) {
        my $db = $self->{config}{db};
        my $dbh = DBI->connect(
            $db->{connect_info},
            $db->{user},
            $db->{password},
            $db->{option},
        ) or die 'db connection error';
        $self->{dbh} = $dbh;
    }
    
    return $self;
}

sub validate {
    my $sth = $self->{dbh}->prepare(qq/select id from block_hash.tweet where is_valid = 0/);
    $sth->execute;
    my $rs = $sth->fetchall_arrayref(+{});
    $sth->finish;

    my @ng_list;
    for my $row (@$rs) {
        my $sth = $self->{dbh}->prepare(qq/select tweet_json from block_hash.tweet where id = ?/);
        $sth->execute($row->{id});
        my $rs = $sth->fetchrow_hashref;
        $sth->finish;

        eval {
            decode_json(encode_utf8($rs->{tweet_json}));
            my $sth = $self->{dbh}->prepare(qq/update tweet set is_valid = 1 where id = ?/);
            $sth->execute($row->{id});
            $sth->finish;
        };
        if ($@) {
            push @ng_list, $row->{id};
            warn Dumper \@ng_list;
            my $sth = $self->{dbh}->prepare(qq/delete from tweet where id in (?)/);
            $sth->execute(join ',', @ng_list);
            $sth->finish;
        }
    }
}

__END__
