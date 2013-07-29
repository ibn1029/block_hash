package BlockHash::Controller::Program;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Program;

use Data::Dumper;

sub display {
    my $self = shift;
    my ($tweets, $pager, $count) = BlockHash::Model::Program->get_tweets({
        tag  => $self->stash('tag') || '',
        date => $self->stash('date') || '',
        page => $self->req->param('page') || 1,
    });
    $self->render(
        tag => $self->stash('tag') || '',
        date => $self->stash('date') || '',
        page => $self->req->param('page') || 1,

        tweets => $tweets,
        tweet_count => $count,
        pager => $pager,
    );
}

1;
