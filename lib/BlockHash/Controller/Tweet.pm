package BlockHash::Controller::Tweet;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Tweet;

use Data::Dumper;

sub search {
    my $self = shift;
    my $p = $self->req->params->to_hash;
    
    # validation
    unless ( $p->{tag} and $p->{date} and $p->{date} =~ /^\d{4}-\d{2}-\d{2}$/ ) {
        $self->redirect_to("/");
        return 0;
    }
    # '#'filter
    $p->{tag}  =~ s/#//g; my $tag = $p->{tag};
    $self->redirect_to("/$tag/$p->{date}");
}

sub search_detail {
    my $self = shift;
    my $p = $self->req->params->to_hash;

    unless ( $p->{tag}
    and $p->{start_date} =~ /^\d{4}-\d{2}-\d{2}$/
    and $p->{end_date}   =~ /^\d{4}-\d{2}-\d{2}$/ 
    and $p->{start_time} =~ /^\d{1,2}$/
    and $p->{end_time}   =~ /^\d{1,2}$/ ) {
        $self->redirect_to("/");
        return 0;
    }
    $p->{tag}  =~ s/#//g; my $tag = $p->{tag};
    $self->redirect_to("/$tag/$p->{start_date}/$p->{start_time}/$p->{end_date}/$p->{end_time}");
}

sub display {
    my $self = shift;

    if ($self->stash('start_date') and $self->stash('end_date')) {
        my ($tweets, $pager, $tweet_count) = BlockHash::Model::Tweet->search_detail({
            tag  => $self->stash('tag'),
            start_date => $self->stash('start_date'),
            start_time => $self->stash('start_time') || '0',
            end_date => $self->stash('end_date'),
            end_time => $self->stash('end_time') || '0',
            page => $self->req->param('page') || 1,
        });
        $self->render(
            tag => $self->stash('tag'),
            start_date => $self->stash('start_date'),
            start_time => $self->stash('start_time') || '0',
            end_date => $self->stash('end_date'),
            end_time => $self->stash('end_time') || '0',
            page => $self->req->param('page') || 1,

            tweets => $tweets,
            tweet_count => $tweet_count,
            pager => $pager,
        );

    } else {
        my ($tweets, $pager, $tweet_count) = BlockHash::Model::Tweet->search({
            tag  => $self->stash('tag'),
            date => $self->stash('date'),
            page => $self->req->param('page') || 1,
        });
        $self->render(
            tag => $self->stash('tag'),
            date => $self->stash('date'),
            page => $self->req->param('page') || 1,

            tweets => $tweets,
            tweet_count => $tweet_count,
            pager => $pager,
        );
    }
}

1;
