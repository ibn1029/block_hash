package BlockHash::Controller::Top;
use Mojo::Base 'Mojolicious::Controller';
use BlockHash::Model::Tweet;

use Data::Dumper;

sub top {
    my $self = shift;
    my ($total_tweets, $hashtags, $last_updated, $tag_cloud, $weekly_moment_job, $weekly_moment) 
        = BlockHash::Model::Tweet->get_status;
    $self->render(
        is_toppage => 1,
        total_tweets => $total_tweets,
        hashtags => $hashtags,
        last_updated => $last_updated,
        tag_cloud => $tag_cloud,
        #weekly_moment_job => $weekly_moment_job,
        #weekly_moment => $weekly_moment,
    );
}

1;
