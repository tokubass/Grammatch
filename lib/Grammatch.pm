package Grammatch;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='3.87';
use 5.008001;

use Teng;
use Teng::Schema::Loader;
use Grammatch::DB;
use Grammatch::DB::Schema;

__PACKAGE__->load_plugins(
    'DBI',
    '+Grammatch::Plugin::Logger',
);

my $schema = Grammatch::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        $c->{db} = Grammatch::DB->new(
            schema       => $schema,
            connect_info => [@$conf],
            # I suggest to enable following lines if you are using mysql.
            on_connect_do => [
                'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            ],
        );
    }
    $c->{db};
}

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $fname = lc("sql/${driver_name}.sql");
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    my $source = do { local $/; <$fh> };
    for my $stmt (split /;/, $source) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

1;
