#!/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use Net::Twitter;
use Encode;
use DBI;
use Time::Piece;
use Time::Seconds;
use JSON;

use Data::Dumper;

# https://dev.twitter.com/apps
# https://dev.twitter.com/docs/api/1.1/get/search/tweets
# https://metacpan.org/module/MMIMS/Net-Twitter-4.00006/lib/Net/Twitter.pod

our $self;
setup();
set_last_tweet_time();

my $query = { q => '#blockfm', count => 100 };
while (1) {
    my $result = $self->{nt}->search($query) or die "twitter api error. $!";
    my $meta = $result->{search_metadata};
    last unless $meta->{count} > 0;

    print "$meta->{count} $result->{statuses}[-1]{id} $result->{statuses}[-1]{created_at}\n";
    store_tweet($result);
    $query->{max_id} = $result->{statuses}[-1]{id};
}
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
    
    unless (defined $self->{nt}) {
        my $twitter = $self->{config}{twitter};
        my $nt = Net::Twitter->new(
            traits   => [qw/API::RESTv1_1/],
            consumer_key        => $twitter->{consumer_key}, 
            consumer_secret     => $twitter->{consumer_secret}, 
            access_token        => $twitter->{access_token},
            access_token_secret => $twitter->{access_token_secret}, 
            ssl => 1,
        ) or die 'twitter oauth error';
        $self->{nt} = $nt;
    }
    return $self;
}

sub set_last_tweet_time {
    my $sth = $self->{dbh}->prepare(qq/select max(created_at) from tweet/);
    $sth->execute;
    my ($last_tweet_time) = $sth->fetchrow_array;
    $self->{last_tweet} = deflate_datetime($last_tweet_time) || '';
    return $self->{last_tweet};
}

sub store_tweet {
    my $result = shift or die;

    my $sth = $self->{dbh}->prepare(qq/insert into block_hash.tweet (tweet_id, hashtags, url, created_at, tweet_json, is_valid) values (?, ?, ?, ?, ?, 0)/);

    for my $tweet (@{$result->{statuses}}) {
        unless (deflate_datetime(inflate_datetime($tweet->{created_at})) - $self->{last_tweet} ) {
            print "new tweet not found. finished.\n";
            exit;
        }

        next if is_duplicate_tweet($tweet);
        $sth->execute(
            $tweet->{id},
            join_hashtags($tweet->{entities}{hashtags}),
            retrive_url($tweet->{entities}{urls}),
            inflate_datetime($tweet->{created_at}),
            encode_json($tweet)
        ) or die 'db insert error';
    }
    $sth->finish;
}

sub is_duplicate_tweet {
    my $tweet = shift or die;
    my $sth = $self->{dbh}->prepare(qq/select count(*) from block_hash.tweet where tweet_id = ?/);
    $sth->bind_param(1, $tweet->{id});
    $sth->execute;
    my ($count) = $sth->fetchrow_array;
    $sth->finish;
    if ($count == 1) {
        print "found duplicated tweet. skipped id: $tweet->{id}\n";
        return 1;
    }
    return 0;
}

sub join_hashtags {
    my $hashtags = shift or die;
    my @tags;
    for my $tag (sort @$hashtags) {
        push @tags, $tag->{text};
    }
    return join ',', @tags;
}

sub retrive_url {
    my $urls = shift or die;
    return $urls->[0]{url} if $urls->[0]{url};
}

sub inflate_datetime {
    my $twitter_date_str = shift or die;
    my $t = Time::Piece->strptime($twitter_date_str, "%a %b %d %H:%M:%S %z %Y");
    return $t->ymd.' '.$t->hms;
}

sub deflate_datetime {
    my $last_tweet_time = shift or return;;
    my $t = Time::Piece->strptime($last_tweet_time, "%Y-%m-%d %H:%M:%S");
    return $t;
}
__END__
