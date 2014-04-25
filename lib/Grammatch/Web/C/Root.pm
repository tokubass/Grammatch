package Grammatch::Web::C::Root;
use strict;
use warnings;

sub root {
    my ($class, $c) = @_;
    
    return $c->render('index.tx');
}

sub logout {
    my ($class, $c) = @_;

    $c->session->expire;
    return $c->redirect('/');
}

1;
