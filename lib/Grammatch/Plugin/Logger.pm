package Grammatch::Plugin::Logger;
use strict;
use warnings;
use utf8;
use Data::Dumper ();
use Log::Dispatch::Config;
use Log::Dispatch::Configurator::Any;
use Amon2::Util ();

{
    package Grammatch::Plugin::Logger::Backend;
    use parent qw/Log::Dispatch::Config/;
}

sub init {
    my ($class, $c, $config) = @_;

    my $conf = $c->config->{'Plugin::Logger'} or die "missing configuration for 'Plugin::Logger'";

    Grammatch::Plugin::Logger::Backend->configure(Log::Dispatch::Configurator::Any->new($conf));
    my $logger = Grammatch::Plugin::Logger::Backend->instance;
    $logger->add_callback(sub {
        my %args = @_;
        return '' unless $args{message};
        if (ref $args{message}) {
            local $Data::Dumper::Terse    = 1;
            local $Data::Dumper::Indent   = 1;
            local $Data::Dumper::Sortkeys = 1;
            $args{message} = Data::Dumper::Dumper($args{message});
        }
        chomp $args{message};
        return $args{message};
    });

    Amon2::Util::add_method($c, 'log', sub { $logger });
}

1;
