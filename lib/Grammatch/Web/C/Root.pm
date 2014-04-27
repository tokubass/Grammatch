package Grammatch::Web::C::Root;
use strict;
use warnings;
use Grammatch::App::Root;

sub root {
    my ($class, $c) = @_;
    my $user_id = $c->session_get();
    return $c->render('index.tx') unless $user_id;

    my $data = Grammatch::App::Root->root($user_id);
    return $c->render('logged_index.tx', $data);
}

sub logout {
    my ($class, $c) = @_;

    $c->session->expire;
    return $c->redirect('/');
}

1;
