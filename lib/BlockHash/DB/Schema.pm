package BlockHash::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
table {
    name 'analyzed_tag';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'tag', type => 12},
        {name => 'num', type => 4},
    );
};

table {
    name 'analyzed_weekly_moment';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'job_id', type => 4},
        {name => 'hashtag', type => 12},
        {name => 'count', type => 4},
        {name => 'count_from', type => 11},
        {name => 'count_to', type => 11},
    );
};

table {
    name 'analyzed_weekly_moment_job';
    pk 'job_id';
    columns (
        {name => 'job_id', type => 4},
        {name => 'span_from', type => 11},
        {name => 'span_to', type => 11},
        {name => 'created_at', type => 11},
    );
};

table {
    name 'hashtag';
    pk 'tag_id';
    columns (
        {name => 'tag_id', type => 4},
        {name => 'hastag', type => 12},
        {name => 'title', type => 12},
        {name => 'created_at', type => 11},
        {name => 'updated_at', type => 11},
    );
};

table {
    name 'program';
    pk 'prog_id';
    columns (
        {name => 'prog_id', type => 4},
        {name => 'prog_date', type => 9},
        {name => 'prog_start', type => 10},
        {name => 'prog_end', type => 10},
        {name => 'title', type => 12},
        {name => 'subtitle', type => 12},
        {name => 'hashtag', type => 12},
        {name => 'created_at', type => 11},
    );
};

table {
    name 'tweet';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'tweet_id', type => 4},
        {name => 'hashtags', type => 12},
        {name => 'url', type => 12},
        {name => 'media_type', type => 12},
        {name => 'media_data', type => 12},
        {name => 'created_at', type => 11},
        {name => 'tweet_json', type => 12},
        {name => 'is_valid', type => 4},
    );

        inflate qr/.+_json/ => sub {
            use JSON;
            use Encode;
            return decode_json(encode_utf8(shift));
        };
        inflate qr/.+_at/ => sub {
            use Time::Piece;
            use Time::Seconds;
            my $t = Time::Piece->strptime(shift, "%Y-%m-%d %H:%M:%S");
            return $t + 9*60*60;
        };
    };

1;
