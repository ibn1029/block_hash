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
my $score = analysis();
update_table($score);
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

sub analysis {
    my $sth = $self->{dbh}->prepare(qq/select hashtags, count(hashtags) as num from tweet group by hashtags/);
    $sth->execute;
    my $rs = $sth->fetchall_arrayref(+{});
    $sth->finish;

    my $score = +{};
    for my $row (@$rs) {
        my @tags = grep {!/blockfm/} split /,/, $row->{hashtags};
        for my $tag (@tags) {
            $tag =~ s/#//;
            $score->{$tag} += $row->{num};
        }
    }
    return $score;
}

sub update_table {
    my $score = shift;

    my $sth = $self->{dbh}->prepare(qq/delete from analyzed_tag/);
    $sth->execute;
    $sth->finish;

    for my $key (keys %$score) {
        my $sth = $self->{dbh}->prepare(qq/insert into analyzed_tag (tag, num) values (?, ?)/);
        $sth->execute($key, $score->{$key});
        $sth->finish;
    }
}

__END__
