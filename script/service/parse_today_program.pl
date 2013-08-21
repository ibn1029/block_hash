#!/bin/env perl
use strict;
use warnings;
use FindBin;
use File::Path;
use DBI;
use Time::Piece;
use Time::Seconds;
use File::Which;
use Test::TCP;
use Selenium::Remote::Driver;
use Web::Query;
use Encode;

use Data::Dumper;

our $self;
my $url = 'http://block.fm';
#my $url = 'http://172.16.100.102:5000/fafaasiiuouurqfaf9989r12.html';
my $t = localtime;
#$t = $ - ONE_DAY * 1;  # only manual
my $today = $t->ymd('');

setup();
my $programs = fetch($url, $today);
update_table($today, $programs);
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

sub fetch {
    my ($url, $today) = @_;

    my $bin= scalar which 'phantomjs';
    my $phantomjs = Test::TCP->new(
        code => sub {
            my $port = shift; # assign undefined local port
            exec $bin, "--webdriver=$port";
            die "cannot execute $bin: $!";
        },
    );

    my $driver = Selenium::Remote::Driver->new(
        remote_server_addr => '127.0.0.1',
        port => $phantomjs->port,
    );
    $driver->debug_off;
    $driver->get($url);
    sleep 2;
    my $res = $driver->get_page_source;
    my @programs;
    my $wq = Web::Query->new_from_html($res);
    $wq->find("#date${today} .tt_time")->each(sub {
        my ($i, $e) = @_;
        my ($start, $end) = split /～/, encode_utf8($e->find('.time')->text);
        my $title_text = encode_utf8($e->find('.title')->text);
        $title_text =~ /(.+)"(.+)"/;
        my $title = $1;
        my $subtitle = $2;
        push @programs, {
            title => $title,
            subtitle => $subtitle,
            prog_start => $start,
            prog_end => $end,
        };
    });
    return \@programs;
}

sub update_table {
    my ($today, $programs) = @_;

    for my $prog (@$programs) {
        my $sth1 = $self->{dbh}->prepare(qq/select count(*) as cnt from program where prog_date = ? and prog_start = ? and  prog_end = ? and title = ?/);
        $sth1->execute(
            $today,
            $prog->{prog_start},
            $prog->{prog_end},
            $prog->{title},
        );
        my $rs1 = $sth1->fetchrow_hashref();
        my $cnt = $rs1->{cnt};
        $sth1->finish;
        next if $cnt;

        my $sth2 = $self->{dbh}->prepare(qq/select hashtag from hashtag where title = ?/);
        $sth2->execute($prog->{title});
        my $rs2 = $sth2->fetchrow_hashref();
        my $hashtag = $rs2->{hashtag} || 'blockfm';
        $sth2->finish;

        my $sth3 = $self->{dbh}->prepare(qq/insert into program (prog_date, prog_start, prog_end, title, subtitle, hashtag, created_at) values (?, ?, ?, ?, ?, ?, now())/);
        $sth3->execute(
            $today,
            $prog->{prog_start},
            $prog->{prog_end},
            $prog->{title},
            $prog->{subtitle},
            $hashtag,
        );
        $sth3->finish;
    }
}

__END__

