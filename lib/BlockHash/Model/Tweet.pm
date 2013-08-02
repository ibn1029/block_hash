package BlockHash::Model::Tweet;
use BlockHash::DB;
use Time::Piece;
use Time::Seconds;
use Data::Page::Navigation;

use Data::Dumper;

my $ROWS = 1;

sub get_status {
    my $self = shift;

    my $db = BlockHash::DB->new;

    my $total_tweets = $db->count('tweet', '*');
    my $rs1 = $db->single_by_sql(qq/select count(*) as hashtags from (select hashtags from tweet group by hashtags) as hashtag_group;/);
    my $hashtags = $rs1->hashtags;
    my $rs2 = $db->single_by_sql(qq/select max(created_at) as last_updated_at from tweet/);
    my $t = $rs2->last_updated_at;
    return $total_tweets, $hashtags, $t->ymd.' '.$t->hms;
}

sub search {
    my $self = shift;
    my $args = shift || croak;    

    $args->{date} =~ /^(\d{4})(\d{2})(\d{2})$/;
    my $t_start = Time::Piece->strptime($args->{date}.' 00:00:00', '%Y-%m-%d %H:%M:%S');
    my $t_end = Time::Piece->strptime($args->{date}.' 23:59:59', '%Y-%m-%d %H:%M:%S');
    $t_start = $t_start - 9*60*60;
    $t_end = $t_end - 9*60*60;

    #my $where = {
    #    hashtags => { like => '%'.$args->{tag}.'%' },
    #    created_at => { between => [$t_start->ymd.' '.$t_start->hms, $t_end->ymd.' '.$t_end->hms] },
    #    is_valid => 1,
    #};

    my ($tweets, $pager, $tweet_count) = $self->_get_tweets($args->{page}, $t_start, $t_end);

    return $tweets, $pager, $tweet_count;
}

sub search_detail {
    my $self = shift;
    my $args = shift || croak;    

    $args->{start_date} =~ /^(\d{4})(\d{2})(\d{2})$/;
    $args->{end_date}   =~ /^(\d{4})(\d{2})(\d{2})$/;
    $args->{start_time} =~ /^\d{1,2}$/;
    $args->{end_time}   =~ /^\d{1,2}$/;
    my $t_start = Time::Piece->strptime($args->{start_date}.' '.$args->{start_time}.':00:00', '%Y-%m-%d %H:%M:%S');
    my $t_end   = Time::Piece->strptime($args->{end_date}  .' '.$args->{end_time}  .':00:00', '%Y-%m-%d %H:%M:%S');
    $t_start = $t_start - 9*60*60;
    $t_end   = $t_end - 9*60*60;

    #my $where = {
    #    hashtags => { like => '%'.$args->{tag}.'%' },
    #    created_at => { between => [$t1->ymd.' '.$t1->hms, $t2->ymd.' '.$t2->hms] },
    #    is_valid => 1,
    #};

    my ($tweets, $pager, $tweet_count) = $self->_get_tweets($args->{page}, $t_start, $t_end);

    return $tweets, $pager, $tweet_count;
}

sub _get_tweets {
    my ($self, $page, $t_start, $t_end) = @_;

    my $db = BlockHash::DB->new;
    my $where = {
        hashtags => { like => '%'.$args->{tag}.'%' },
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
        push @tweets, {
            tweet =>$row->tweet_json,
            date => $t_str,
            media_type => $row->media_type,
            media_data => $row->media_data,
        };
    }
    
    return \@tweets, $pager, $tweet_count;
}

1;
