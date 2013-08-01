package BlockHash::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
table {
    name 'archive';
    pk 'archive_id';
    columns (
        {name => 'archive_id', type => 4},
        {name => 'prog_id', type => 4},
        {name => 'url', type => 12},
        {name => 'started_at', type => 11},
        {name => 'stopped_at', type => 11},
    );
};

table {
    name 'program';
    pk 'prog_id';
    columns (
        {name => 'prog_id', type => 4},
        {name => 'prog_name', type => 12},
        {name => 'hash_tags', type => 12},
        {name => 'note', type => 12},
        {name => 'prog_week_day', type => 4},
        {name => 'prog_day', type => 9},
        {name => 'prog_start_at', type => 10},
        {name => 'prog_end_at', type => 10},
        {name => 'created_at', type => 11},
        {name => 'updated_at', type => 11},
        {name => 'created_by', type => 12},
        {name => 'updated_by', type => 12},
    );
};

table {
    name 'tweet';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'tweet_id', type => 4},
        {name => 'hashtags', type => 12},
        {name => 'created_at', type => 11},
        {name => 'tweet_json', type => 12},
        {name => 'url', type => 12},
        {name => 'media_type', type => 12},
        {name => 'media_data', type => 12},
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
