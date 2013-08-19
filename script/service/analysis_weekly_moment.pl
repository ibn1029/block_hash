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
our $PERIOD = 5; # minute

setup();
my ($span, $score) = analysis();
update_table($span, $score);
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
    # 日曜日に処理する前提
    my $t = localtime;
    my $t_deadline = $t - ONE_DAY;
    my $deadline = $t_deadline->ymd.' 23:59:59';
    my $t_last_one_week = $t - ONE_WEEK;
    my $last_one_week = $t_last_one_week->ymd.' 00:00:00';
    my %span = (
        from => Time::Piece->strptime($last_one_week, '%Y-%m-%d %H:%M:%S'), 
        to => Time::Piece->strptime($deadline, '%Y-%m-%d %H:%M:%S'),
    );

    # １周間のツイート総数
    my $total_sth = $self->{dbh}->prepare(qq/select count(*) as total from tweet where '$last_one_week' <= created_at and  created_at < '$deadline'/);
    $total_sth->execute;
    my $total_rs = $total_sth->fetchrow_hashref();
    $total_sth->finish;
    my $total = $total_rs->{total};

    # １周間のハッシュタグ種類
    my $tag_sth = $self->{dbh}->prepare(qq/select hashtags from tweet where '$last_one_week' <= created_at and  created_at < '$deadline' group by hashtags/);
    $tag_sth->execute;
    my $tag_rs = $tag_sth->fetchall_arrayref(+{});
    $tag_sth->finish;
    my %tags;
    for my $row (@$tag_rs) {
        map {
            my $tag = $_;
            $tag =~ s/\s*(\S+)\s*/$1/;
            $tag =~ s/#(.+)/$1/;
            $tags{encode_utf8($tag)} = +{};
        } split /,/, $row->{hashtags};
    }
    delete $tags{blockfm};

    my @score;
    my $from = $span{from};
    my $to = $span{to};
    while ($from->epoch < $to->epoch) {
        my $to = $from + 60 * $PERIOD;
        my $from_str = $from->ymd.' '.$from->hms;
        my $to_str = $to->ymd.' '.$to->hms;

        my $sth = $self->{dbh}->prepare(qq/select hashtags from tweet where created_at between "$from_str" and "$to_str"/);
        $sth->execute;
        my $rs = $sth->fetchall_arrayref(+{});
        $sth->finish;

        $from  = $from + 60 * $PERIOD;
        next unless scalar @$rs;

        # 時間内のhashtag毎のtweet件数を集計
        my %tag_count;
        for my $row (@$rs) {
            my $tag_str = $row->{hashtags};
            for my $tag (keys %tags) {
                if ($tag_str =~ /$tag/) {
                    $tag_count{$tag}++;         
                }
            }
        }

        # 時間内で一番tweet数の多いhashtagを選出
        my %max = ( hashtag => 'N/A', count => 0);
        for my $tag (keys %tag_count) {
            if ($tag_count{$tag} > $max{count}) {
                %max = (hashtag => $tag, count => $tag_count{$tag});
            }
        }

        push @score, {
            from => $from_str,
            to => $to_str,
            hashtag => $max{hashtag},
            count => $max{count},
        };
    }
    return \%span, \@score;
}

sub update_table {
    my ($span, $score) = @_;

    my $sth = $self->{dbh}->prepare(qq/insert into analyzed_weekly_moment_job (span_from, span_to, created_at) values (?, ?, now())/);
    $sth->execute(
        $span->{from}->ymd.' '.$span->{from}->hms,
        $span->{to}->ymd.' '.$span->{to}->hms,
    );
    $sth->finish;

    my $sth2 = $self->{dbh}->prepare(qq/select last_insert_id() as last_job_id from analyzed_weekly_moment_job/);
    $sth2->execute();
    my $rs2 = $sth2->fetchrow_hashref();
    my $last_job_id = $rs2->{last_job_id};
    $sth->finish;

    for my $e (@$score) {
        my $sth = $self->{dbh}->prepare(qq/insert into analyzed_weekly_moment (job_id, hashtag, count, count_from, count_to) values (?, ?, ?, ?, ?)/);
        $sth->execute(
            $last_job_id,
            $e->{hashtag},
            $e->{count},
            $e->{from},
            $e->{to},
        );
        $sth->finish;
    }
}

__END__
