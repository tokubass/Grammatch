use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use Grammatch::Web;
use Grammatch;
use Plack::Session::Store::Redis;
use Plack::Session::State::Cookie;
use DBI;

{
    my $c = Grammatch->new();
    $c->setup_schema();
}
my $config = Grammatch->config || die "Missing configuration";
builder {
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/static/)},
        root => File::Spec->catdir(dirname(__FILE__));
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => File::Spec->catdir(dirname(__FILE__), 'static');
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Session',
        state => Plack::Session::State::Cookie->new(
            %{$config->{'Plack::Session::State::Cookie'}},
        ),
        store => Plack::Session::Store::Redis->new(
            %{$config->{'Plack::Session::Store::Redis'}},
        );
    Grammatch::Web->to_app();
};
