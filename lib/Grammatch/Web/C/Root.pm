package Grammatch::Web::C::Root;
use strict;
use warnings;
use utf8;
use Grammatch::App::User;

sub root {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->render('index.tx') unless $logged_user_id;

    my $data = Grammatch::App::User->user($logged_user_id);
    return $c->render('user/user.tx', { %{$data},
        link_to_own_user_page => 1,
    });
}

sub logout {
    my ($class, $c) = @_;
    $c->session->expire;
    return $c->redirect('/');
}

1;
