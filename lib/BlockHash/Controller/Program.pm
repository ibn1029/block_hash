package BlockHash::Controller::Program;
use Mojo::Base 'Mojolicious::Controller';

sub display {
    my $self = shift;

    my $result = $self->model('Program')->get_tweets({
        prog_name => $self->stash('prog_name') || '',
        date      => $self->stash('date') || '',
    });

    #if ($result->has_error) {
    #    $self->stash->{error_messages} = $result->error_messages;
    #    return $self->render('/top');
    #}
    $self->render( tweets => $result );
}

1;
