#!/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use Encode;
use DBI;
use Time::Piece;
use JSON;
use Data::Dumper;

# https://dev.twitter.com/apps
# https://dev.twitter.com/docs/api/1.1/get/search/tweets
# https://metacpan.org/module/MMIMS/Net-Twitter-4.00006/lib/Net/Twitter.pod

my $conf = do File::Spec->catdir($FindBin::Bin, '..', 'config', 'block_hash.development.conf') 
    or die 'config file not found';

our $dbh = DBI->connect(
    $conf->{db}{connect_info},
    $conf->{db}{user},
    $conf->{db}{password},
    $conf->{db}{option},
) or die 'db connection error';

my $add_tag = $ARGV[0] || 'remo_con';
my @tl;

my $sth = $dbh->prepare(qq/select tweet_json from tweet where hashtags like ? and created_at >= ? and created_at < ? order by created_at/);
$sth->bind_param(1, '%'.$add_tag.'%');
$sth->bind_param(2, $ARGV[1]);
$sth->bind_param(3, $ARGV[2]);
$sth->execute;
my $rs = $sth->fetchall_arrayref(+{});
$sth->finish;
$dbh->disconnect;

for my $row (@{$rs}) {
    my $tweet = decode_json(encode_utf8($row->{tweet_json}));
    print encode_utf8($tweet->{user}{name}).' @'.$tweet->{user}{screen_name}."\n";
    print "\t".encode_utf8($tweet->{text})."\n";
    print "\t".inflate_datetime($tweet->{created_at})."\n";
    push @tl, $tweet;
}

print "\n####\n";
print "tags: #blockfm #$add_tag\n";
print "tweet count: ".scalar @tl."\n";

sub inflate_datetime {
    my $twitter_date_str = shift or die;
    my $t = Time::Piece->strptime($twitter_date_str, "%a %b %d %H:%M:%S %z %Y");
    my $jst = $t + 9*60*60;
    return $jst->ymd.' '.$jst->hms;
}

__END__
