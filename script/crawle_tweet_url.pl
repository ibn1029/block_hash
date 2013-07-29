#!/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use LWP::UserAgent;
use Encode;
use DBI;
use HTML::Entities;
use Time::Piece;
use Time::Seconds;
use JSON;

use Data::Dumper;

# https://dev.twitter.com/apps
# https://dev.twitter.com/docs/api/1.1/get/search/tweets
# https://metacpan.org/module/MMIMS/Net-Twitter-4.00006/lib/Net/Twitter.pod

our $self;
setup();
my $url_list = get_uncheck_urls();
crawle($url_list);
exit;

#--------------------------------------------------------------------------------------------
sub setup {
    unless (defined $self->{config}) {
        my $conf = do File::Spec->catdir($FindBin::Bin, '..', 'config', 'block_hash.development.conf')  or die "config file not found. $!";
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
    
    unless (defined $self->{ua}) {
        my $ua = LWP::UserAgent->new(timeout => 10) or die 'lwp error';
        $self->{ua} = $ua;
    }
    return $self;
}

sub get_uncheck_urls {
    my $sth = $self->{dbh}->prepare(qq/select url from block_hash.tweet where url is not null and (media_type is null or media_data is null) group by url/);
    $sth->execute;
    my $rs = $sth->fetchall_arrayref(+{});
    my @url_list;
    for my $row (@$rs) {
        push @url_list, $row->{url};
    }
    return \@url_list;
}

sub crawle {
    my $url_list = shift;
    my $ua = $self->{ua};
    for my $url (@$url_list) {
        my $res = $ua->get($url);
        next $res->status_line unless $res->is_success;
        my $uri = $res->request->uri->as_string;

        if ($uri =~ /instagram\.com/) {
            _media_type_is_instagram($url, $uri);
        } elsif ($uri =~ /vine\.co/) {
            _media_type_is_vine($url, $uri);
        } elsif ($uri =~ /youtube\.com/) {
            _media_type_is_youtube($url, $uri);
        } elsif ($uri =~ /ow\.ly/) {
            _media_type_is_owly($url, $uri);
        } elsif ($uri =~ /soundcloud\.com/) {
            _media_type_is_soundcloud($url, $uri);
        } else {
            _media_type_is_website($url, $uri);
        } 
    }

}

sub _media_type_is_instagram {
    my ($url, $data) = @_;
    my $decoded_url = decode_entities($data);
    _resolve_media_data('instagram', $url, $decoded_url);
}
sub _media_type_is_vine {
    my ($url, $data) = @_;
    my $decoded_url = decode_entities($data);
    _resolve_media_data('vine', $url, $decoded_url);
}
sub _media_type_is_youtube {
    my ($url, $data) = @_;
    my $decoded_url = decode_entities($data);
    _resolve_media_data('youtube', $url, $decoded_url);
}
sub _media_type_is_owly {
    my ($url, $data) = @_;
    my $decoded_url = decode_entities($data);
    _resolve_media_data('owly', $url, $decoded_url);
}
sub _media_type_is_soundcloud {
    my ($url, $data) = @_;
    my $decoded_url = decode_entities($data);
    _resolve_media_data('soundcloud', $url, $decoded_url);
}
sub _media_type_is_website {
    my ($url, $data) = @_;
    _resolve_media_data('web_site', $url, $data);
}

sub _resolve_media_data {
    my ($media_type, $url, $media_data) = @_;
    my $sth = $self->{dbh}->prepare(qq/update block_hash.tweet set media_type = ?, media_data = ? where url = ?/);
    $sth->execute($media_type, $media_data, $url);
    return;
}

__END__
