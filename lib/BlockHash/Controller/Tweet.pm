package BlockHash::Controller::Tweet;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Tweet;

use Data::Dumper;

sub search {
    my $self = shift;

    my $p = $self->req->params->to_hash;
    $self->_validate($p);

    # '#'filter
    $p->{tag}  =~ s/#//g; my $tag = $p->{tag};
    $self->redirect_to("/$tag/$p->{date}");
}

sub search_detail {
    my $self = shift;

    my $p = $self->req->params->to_hash;
    $self->_validate_detail($p);

    $p->{tag}  =~ s/#//g; my $tag = $p->{tag};
    $self->redirect_to("/$tag/$p->{start_date}/$p->{start_time}/$p->{end_date}/$p->{end_time}");
}

sub display {
    my $self = shift;

    # 詳細検索
    if ($self->stash('start_date') and $self->stash('end_date')) {

        $self->_validate_detail($self->stash);

        my $tweet_btn_text = '#blockfm #'.$self->stash('tag').' '
                            .$self->stash('start_date').' '.$self->stash('start_time').'時から'
                            .$self->stash('end_date').' '.$self->stash('end_time')
                            .'時台のツイート検索結果';
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
            tweet_btn_text => $tweet_btn_text,

            tweets => $tweets,
            tweet_count => $tweet_count,
            pager => $pager,
        );

    # 検索
    } else {
        $self->_validate($self->stash);

        my $tweet_btn_text = '#blockfm #'.$self->stash('tag').' '
                            .$self->stash('date').'のツイート検索結果';
        my ($tweets, $pager, $tweet_count) = BlockHash::Model::Tweet->search({
            tag  => $self->stash('tag'),
            date => $self->stash('date'),
            page => $self->req->param('page') || 1,
        });
        $self->render(
            tag => $self->stash('tag'),
            date => $self->stash('date'),
            page => $self->req->param('page') || 1,
            tweet_btn_text => $tweet_btn_text,

            tweets => $tweets,
            tweet_count => $tweet_count,
            pager => $pager,
        );
    }
}

sub _validate {
    my ($self, $p) = @_;
    unless ( $p->{tag} and $p->{date} and $p->{date} =~ /^\d{4}-\d{2}-\d{2}$/ ) {
        $self->redirect_to("/");
        return 0;
    }
}

sub _validate_detail {
    my ($self, $p) = @_;
    unless ( $p->{tag}
    and $p->{start_date} =~ /^\d{4}-\d{2}-\d{2}$/
    and $p->{end_date}   =~ /^\d{4}-\d{2}-\d{2}$/ 
    and $p->{start_time} =~ /^\d{1,2}$/
    and $p->{end_time}   =~ /^\d{1,2}$/ ) {
        $self->redirect_to("/");
        return 0;
    }
}
1;
