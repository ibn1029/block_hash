package BlockHash::DB;
use strict;
use warnings;
use utf8;

use BlockHash;
use BlockHash::DB::Schema;

sub new { return bless +{},  shift; }

sub config {
    my $self = shift;
    if (! defined $self->{config}) {
        my $app = BlockHash->new;
        $self->{config} = $app->config;
    }
    return $self->{config};
}

sub schema {
    my $self = shift;
    if (! defined $self->{schema}) {
        my $db = $self->config->{db};
        my $schema = BlockHash::DB::Schema->connect(
            $db->{connect_info},
            $db->{user},
            $db->{password},
            $db->{option},
        $self->{schema} = $schema;
    }
    return $self->{schema};
}

1;

