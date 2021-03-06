package BlockHash;
use Mojo::Base 'Mojolicious';

use HTML::FillInForm::Lite 'fillinform';
use Text::Xslate 'html_builder';
use Text::AutoLink;
use Module::Load 'load';
use Time::Piece;
use Time::Seconds;

sub startup {
    my $self = shift;

    # Config
    $self->plugin('Config', { file => 'config/block_hash.conf'});

    $self->app->secret('BlockHash20130804');

    # Profiling
    if ($self->mode eq 'development') {
        #use Devel::KYTProf
    }

    # View
    $self->plugin( xslate_renderer => {
        template_options => {
            syntax => 'TTerse',
            function => {
                fillinform => html_builder(\&fillinform),
                highlight => html_builder {
                    my $str = shift || return;
                    $str =~ s!(@\w+)!<span class="id">$1<\/span>!g;
                    my $auto = Text::AutoLink->new;
                    $str = $auto->parse_string($str);
                    return $str;
                },
                for_owly => sub {
                    my $str = shift || return;
                    my @splited = split '/', $str;
                    return $splited[-1];
                },
                for_youtube => sub {
                    my $str = shift || return;
                    $str =~ /=(\w+)$/;
                    my $id = $1;
                    return $id;
                },
                today => sub {
                    my $t = localtime;
                    return $t->ymd;
                },
                yesterday => sub {
                    my $t = localtime;
                    $t -= ONE_DAY;
                    return $t->ymd;
                },
                week_ago => sub {
                    my $t = localtime;
                    $t = $t - 60 * 60 * 24 * 7;
                    return $t->ymd;
                },
            },
        },
    });

    # Router
    my $r = $self->routes;
    $r->namespaces(['BlockHash::Controller']);

    $r->get('/')->to('top#top');
    $r->post('/search')->to('tweet#search');
    $r->post('/search/detail')->to('tweet#search_detail');
    $r->get('/(:tag)/(:date)')->to('tweet#display');
    $r->get('/(:tag)/(:start_date)/(:start_time)/(:end_date)/(:end_time)')->to('tweet#display');
}

1;
