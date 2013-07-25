package BlockHash;
use Mojo::Base 'Mojolicious';

use HTML::FillInForm::Lite 'fillinform';
use Text::Xslate 'html_builder';
use Text::AutoLink;
use Module::Load 'load';

sub startup {
    my $self = shift;

    # Config
    $self->plugin('Config', { file => 'config/block_hash.conf'});

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
            },
        },
    });

    # Helper method
    $self->helper( model => sub {
        my ($self, $model_class) = @_;
        my $pkg = "BlockHash::Model::$model_class";
        load $pkg;
        return $pkg->new;
    });

    # Router
    my $r = $self->routes;
    $r->namespaces(['BlockHash::Controller']);

    $r->get('/')                            ->to('top#index');
    $r->get('/(:prog_name)/(:date)')        ->to('program#display');
}

1;
