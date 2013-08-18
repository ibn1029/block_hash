#!/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use Time::Piece;
use Time::Seconds;
use Encode;
use DBI;
use JSON;

use Data::Dumper;

our $self;
setup();
my $score = analysis();
#update_table($score);
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
    my $t =localtime;
    my $t_last_one_week = $t - (60*60*24*7);
    my $last_one_week = $t_last_one_week->ymd.' '.$t_last_one_week->hms;
    # １周間のツイート総数
    my $total_sth = $self->{dbh}->prepare(qq/select count(*) as total from tweet where created_at > '$last_one_week'/);
    $total_sth->execute;
    my $total_rs = $total_sth->fetchrow_hashref();
    $total_sth->finish;
    my $total = $total_rs->{total};

    # １周間のハッシュタグ種類
    my $tag_sth = $self->{dbh}->prepare(qq/select hashtags from tweet where created_at > '$last_one_week' group by hashtags/);
    $tag_sth->execute;
    my $tag_rs = $tag_sth->fetchall_arrayref(+{});
    $tag_sth->finish;
    my %tags;
    for my $row (@$tag_rs) {
        map {
            my $tag = $_;
            $tags{encode_utf8($_)} = +{};
        } split /,/, $row->{hashtags};
    }
    delete $tags{blockfm};

    my $score;
    my $t_from = $t_last_one_week;
    while ($t_from->epoch <= $t->epoch) {
        my $t_to = $t_from + 60*5;
        my $from = $t_from->ymd.' '.$t_from->hms;
        my $to = $t_to->ymd.' '.$t_to->hms;

        my $sth = $self->{dbh}->prepare(qq/select hashtags from tweet where created_at between '$from' and '$to'/);
        $sth->execute;
        my $rs = $sth->fetchall_arrayref(+{});
        $sth->finish;

        $t_from  = $t_from + 60*5;
        next unless scalar @$rs;

        for my $row (@$rs) {
            my $tag_str = $row->{hashtags};
            for my $tag (keys %tags) {
                my $count = 0;
                if (defined $score->{$tag} and $score->{$tag}{from} eq "$from" and $score->{$tag}{to} eq "$to") {
                    $count = $score->{$tag}{count}; 
                }
                if ($tag_str =~ /$tag/) {
                    $score->{$tag} = {
                        from => $from,
                        to => $to,
                        count => $count++,
                    };
                }
            }
        }
    }

warn Dumper $score;

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
