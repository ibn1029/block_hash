package BlockHash::Controller::Tweet;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Program;

use Data::Dumper;

sub search {
    my $self = shift;
    my $p = $self->req->params->to_hash;
    $self->redirect_to("/") unless $p->{tag} and $p->{date};
    my $tag = $p->{tag};
    my $date = $p->{date};
    $self->redirect_to("/$tag/$date");
}

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
