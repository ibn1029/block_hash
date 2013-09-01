package BlockHash::DB;
use strict;
use warnings;
use utf8;
use parent 'Teng';
__PACKAGE__->load_plugin('Pager');
__PACKAGE__->load_plugin('Count');

use DBI;
use BlockHash;

sub new {
    my $class = shift;
    my $dbh = _dbh_setup();
    return $class->SUPER::new(dbh => $dbh);
}

sub _dbh_setup {
    my $app = BlockHash->new;
    my $conf = $app->config;
    my $db = $conf->{db};
    my $dbh = DBI->connect(
        $db->{connect_info},
        $db->{user},
        $db->{password},
        $db->{option},
    ) or die "db connection error. $!";
    return $dbh;
}

1;
