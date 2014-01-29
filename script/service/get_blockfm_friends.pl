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

my @friend_ids;
my $result = $self->{nt}->friends_ids({ screen_name => 'blockfmjp'}) or die "failed twitter api. $!\n";
push @friend_ids, @{$result->{ids}};

open my $fh, '>', File::Spec->catdir($FindBin::Bin, qw/.. .. config blockfm_friends.pl/);
my $joined_ids = join ',', @friend_ids;
print $fh $joined_ids;
close $fh;

exit;

#--------------------------------------------------------------------------------------------
sub setup {
    unless (defined $self->{config}) {
        my $conf = do File::Spec->catdir($FindBin::Bin, 
            qw/.. .. config block_hash.development.conf/)
            or die "config file not found. $!";
        $self->{config} = $conf;
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

__END__
