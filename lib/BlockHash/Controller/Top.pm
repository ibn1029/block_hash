package BlockHash::Controller::Top;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Program;

use Data::Dumper;

sub top {
    my $self = shift;
    my ($total_tweets, $last_updated) = BlockHash::Model::Program->get_status;
    $self->render(
        is_toppage => 1,
        total_tweets => $total_tweets,
        last_updated => $last_updated,
    );
}

1;
