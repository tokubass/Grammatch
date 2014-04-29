use strict;
use warnings;
use Cinnamon::DSL;

role vps => 'vps', {
    deploy_to => '/home/papix/app/grammatch',
    service   => 'grammatch',
};

task deploy => sub {
    my ($host) = @_;
    my $deploy_to = get('deploy_to');
    my $service   = get('service'); 

    run 'git', 'push', 'origin', 'master'; 
    remote {
        run 'cd', $deploy_to, '&&', 'git', 'pull'; 
        sudo 'supervisorctl', 'restart', $service;
    } $host;
};

task restart => sub {
    my ($host) = @_;
    my $service = get('service'); 
    remote {
        sudo 'supervisorctl', 'restart', $service;
    } $host;
};
