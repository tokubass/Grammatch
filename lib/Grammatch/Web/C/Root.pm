package Grammatch::Web::C::Root;
use strict;
use warnings;

sub root {
    my ($class, $c) = @_;

    return $c->render('index.tx',{
        id => $c->session->get('signin_twitter_screen_name') || 'undefine',
    });
}

sub logout {
    my ($class, $c) = @_;

    $c->session->expire;
    return $c->redirect('/');
}

1;
