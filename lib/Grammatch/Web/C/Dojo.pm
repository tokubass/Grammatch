package Grammatch::Web::C::Dojo;
use strict;
use warnings;
use Grammatch::Model::Dojo;
use Grammatch::Model::User;

sub dojo {
    my ($class, $c, $param) = @_;
    my $dojo_id = $param->{id};
    my $dojo_data = Grammatch::Model::Dojo->dojo($dojo_id);  
    return $c->redirect('/') unless $dojo_data;

    my $user_id = $c->session_get();
    return $c->redirect('/dojo') if $user_id && $user_id == $dojo_data->user_id;

    return $c->render('dojo/dojo.tx',{
        dojo_data  => $dojo_data,
        dojo_owner => $dojo_data->owner,
    });
}
sub my_dojo {
    my ($class, $c) = @_;
    my $user_id = $c->session_get();
    return $c->redirect('/') unless $user_id;
 
    my $user_data = Grammatch::Model::User->user($user_id);
    return $c->redirect('/') unless $user_data;
    return $c->redirect('/') unless $user_data->dojo_id;

    my $dojo_data = $user_data->his_dojo;
    return $c->redirect('/') unless $dojo_data;

    return $c->render('dojo/dojo.tx',{
        dojo_data  => $dojo_data,
        dojo_owner => $dojo_data->owner,
    });
}

sub create {
    my ($class, $c) = @_;
    my $user_id = $c->session_get();
    return $c->redirect('/') unless $user_id;

    my $dojo_id = Grammatch::Model::Dojo->create($user_id);
    return $c->redirect('/user') unless $dojo_id;
    
    return $c->redirect('/dojo');
}

1;
