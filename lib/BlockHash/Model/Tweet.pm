package BlockHash::Model::Tweet;
use BlockHash::DB;
use Time::Piece;
use Time::Seconds;
use Data::Page::Navigation;

use Data::Dumper;

my $ROWS = 30;

sub get_status {
    my $self = shift;

    my $db = BlockHash::DB->new;

    my $total_tweets = $db->count('tweet', '*');

    my $rs1 = $db->single_by_sql(qq/select count(*) as hashtags from (select hashtags from tweet group by hashtags) as hashtag_group;/);
    my $hashtags = $rs1->hashtags;

    my $rs2 = $db->single_by_sql(qq/select max(created_at) as last_updated_at from tweet/);
    my $t = $rs2->last_updated_at;

    my $rs3 = $db->search(analyzed_tag => {});
    my $rows = $rs3->all;
    my $max = 0;
    for my $row (@$rows) {
        $max = $row->num if $row->num > $max;
    }
    my @tag_cloud;
    for my $row (@$rows) {
        push @tag_cloud , {
            tag => $row->tag,
            num => $row->num,
            ratio => $row->num / $max,
        };
    }

    return $total_tweets, $hashtags, $t->ymd.' '.$t->hms, \@tag_cloud;
}

sub search {
    my $self = shift;
    my $args = shift || croak;    

    return 0 unless $args->{date} =~ /^(\d{4})-(\d{2})-(\d{2})$/;

    my $t_start = Time::Piece->strptime($args->{date}.' 00:00:00', '%Y-%m-%d %H:%M:%S');
    my $t_end = Time::Piece->strptime($args->{date}.' 23:59:59', '%Y-%m-%d %H:%M:%S');
    $t_start = $t_start - 9*60*60;
    $t_end = $t_end - 9*60*60;

    my ($tweets, $pager, $tweet_count) = $self->_get_tweets(
        $args->{tag},
        $args->{page},
        $t_start,
        $t_end
    );
    return $tweets, $pager, $tweet_count;
}

sub search_detail {
    my $self = shift;
    my $args = shift || croak;    

    return 0 unless $args->{start_date} =~ /^(\d{4})-(\d{2})-(\d{2})$/;
    return 0 unless $args->{end_date}   =~ /^(\d{4})-(\d{2})-(\d{2})$/;
    return 0 unless $args->{start_time} =~ /^\d{1,2}$/;
    return 0 unless $args->{end_time}   =~ /^\d{1,2}$/;

    my $t_start = Time::Piece->strptime($args->{start_date}.' '.$args->{start_time}.':00:00', '%Y-%m-%d %H:%M:%S');
    my $t_end   = Time::Piece->strptime($args->{end_date}  .' '.$args->{end_time}  .':59:59', '%Y-%m-%d %H:%M:%S');
    $t_start = $t_start - 9*60*60;
    $t_end   = $t_end - 9*60*60;

    my ($tweets, $pager, $tweet_count) = $self->_get_tweets(
        $args->{tag},
        $args->{page},
        $t_start,
        $t_end
    );
    return $tweets, $pager, $tweet_count;
}

sub _get_tweets {
    my ($self, $tag, $page, $t_start, $t_end) = @_;

    my $db = BlockHash::DB->new;
    my $where = {
        hashtags => { like => '%'.$tag.'%' },
        created_at => { between => [$t_start->ymd.' '.$t_start->hms, $t_end->ymd.' '.$t_end->hms] },
        is_valid => 1,
    };
    my ($rs) = $db->search_with_pager('tweet',
        $where,
        {
            order_by => 'created_at',
            page => $page || 1, 
            rows => $ROWS,
        }
    );

    # make pager
    my $tweet_count = $db->count('tweet', '*', $where);
    my $pager = Data::Page->new(
        $tweet_count,
        $ROWS,
        $page || 1,
    );

    my @tweets;
    for my $row (@$rs) {
        my $t = $row->created_at;
        my $t_str = $t->ymd.' '.$t->hms;
        my $tweet_json = $row->tweet_json;
        my $screen_name = $tweet_json->{user}{screen_name};
        push @tweets, {
            tweet => $tweet_json,
            date => $t_str,
            media_type => $row->media_type,
            media_data => $row->media_data,
            blockfm_friend => _check_blockfm_friend($screen_name),
        };
    }

    return \@tweets, $pager, $tweet_count;
}

sub _check_blockfm_friend {
    my ($self, $id) = @_;

    return 1;
}

1;

