package Grammatch::Web::C::User;
use strict;
use warnings;
use Grammatch::Model::User;

sub user {
    my ($class, $c, $param) = @_;
    my $param_user_id   = $param->{id};
    my $session_user_id = $c->session_get();

    my $user_id = $param_user_id || $session_user_id || undef;
    return $c->redirect('/') unless $user_id;
    return $c->redirect('/user') if $param_user_id == $session_user_id;

    my $user_data = Grammatch::Model::User->user($user_id);
    return $c->redirect('/') unless $user_data;

    return $c->render('user/user.tx',{
        user_data => $user_data,
        dojo_data => $user_data->his_dojo,
    });
}

1;
