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

sub edit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $data = Grammatch::App::User->user($logged_user_id);
    return $c->render('user/edit.tx', $data);
}

1;
