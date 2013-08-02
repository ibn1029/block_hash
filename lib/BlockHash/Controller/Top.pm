package BlockHash::Controller::Top;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Tweet;

use Data::Dumper;

sub top {
    my $self = shift;
    my ($total_tweets, $hashtags, $last_updated) = BlockHash::Model::Tweet->get_status;
    $self->render(
        is_toppage => 1,
        total_tweets => $total_tweets,
        hashtags => $hashtags,
        last_updated => $last_updated,
    );
}

1;
