package Grammatch::Web::C::User;
use strict;
use warnings;
use Grammatch::App::User;

sub user {
    my ($class, $c, $param) = @_;
    my $data = Grammatch::App::User->user($param->{id});

    return $c->redirect('/') unless $data; 
    return $c->render('user/user.tx', $data);
}

1;
