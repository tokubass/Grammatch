package Grammatch::Web::C::Dojo;
use strict;
use warnings;
use Grammatch::Model::Dojo;

sub create {
    my ($class, $c) = @_;
    my $user = $c->auth();
    return $c->redirect('/') unless $user;

    my $dojo_id = Grammatch::Model::Dojo->create($user->{user_id});
    return $c->redirect('/user') unless $dojo_id;
    
    return $c->redirect('/dojo');
}

1;
