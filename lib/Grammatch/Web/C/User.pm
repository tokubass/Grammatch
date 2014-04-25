package Grammatch::Web::C::User;
use strict;
use warnings;
use Grammatch::Model::User;

sub profile {
    my ($class, $c) = @_;
    my $user = $c->auth();
    return $c->redirect('/') unless $user;

    my $user_data = Grammatch::Model::User->user($user->{user_id});
    return $c->render('user/user.tx',{
        user_data => $user_data,
    });
}

1;
