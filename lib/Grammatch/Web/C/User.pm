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

    my $user_data = Grammatch::App::User->profile($logged_user_id);
    return $c->render('user/edit.tx', { user_data => $user_data });
}

sub commit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $params = $c->req->parameters();
    $c->form(
        user_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]], 
    );
    if ($c->form->has_error) {
        my $errors;
        return $c->render('user/edit.tx', { user_data => $params->as_hashref, form => $c->form });
    }

    Grammatch::App::User->commit($logged_user_id, $params);
    return $c->redirect('/');
}

1;
