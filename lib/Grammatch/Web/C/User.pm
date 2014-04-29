package Grammatch::Web::C::User;
use strict;
use warnings;
use utf8;
use Grammatch::App::User;

sub user {
    my ($class, $c, $path_param) = @_;
    my $data = Grammatch::App::User->user( user_id => $path_param->{user_id} );
    return $c->redirect('/') unless $data; 
    return $c->render('user/user.tx', $data);
}

# require login
sub edit_form {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $user = Grammatch::App::User->edit_form( user_id => $logged_user_id );
    return $c->render('user/edit.tx', { user => $user });
}

sub edit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    $c->form(
        user_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]], 
    );
    my $params = $c->req->parameters->as_hashref;
    if ($c->form->has_error) {
        return $c->render('user/edit.tx', { user => $params, form => $c->form });
    }

    Grammatch::App::User->edit(
        user_id => $logged_user_id,
        params  => $params
    );
    return $c->redirect('/');
}

1;
