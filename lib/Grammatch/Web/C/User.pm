package Grammatch::Web::C::User;
use strict;
use warnings;
use Grammatch::Model::User;

sub user {
    my ($class, $c, $param) = @_;
    my $user_id = $param->{id};

    my $user_data = Grammatch::Model::User->user($user_id);
    return $c->redirect('/') unless $user_data; 
    my $dojo_list = Grammatch::Model::User->dojo_list($user_id);
    return $c->redirect('/') unless $dojo_list; 
    
    return $c->render('user/user.tx',{
        user_data => $user_data,
        dojo_data => $user_data->dojo,
        dojo_list => $dojo_list,
    });
}

1;
