package Grammatch::Web::C::User;
use strict;
use warnings;
use Grammatch::Model::User;

sub user {
    my ($class, $c, $param) = @_;
    my $user_id = $param->{id};

    my $user_data = Grammatch::Model::User->user($user_id);
    return $c->redirect('/') unless $user_data; 
    
    return $c->render('user/user.tx',{
        user_data => $user_data,
        dojo_data => $user_data->dojo,
    });
}

1;
