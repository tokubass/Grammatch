package Grammatch::Web::C::Dojo;
use strict;
use warnings;
use Grammatch::Model::Dojo;

sub dojo {
    my ($class, $c, $param) = @_;
    my $dojo_id = $param->{id};
    my $user_id = $c->session_get();

    my $dojo_data = Grammatch::Model::Dojo->dojo($dojo_id);
    return $c->redirect('/') unless $dojo_data; 

    my $owner = $dojo_data->owner;
    return $c->redirect('/') unless $owner; 

    return $c->render('dojo/dojo.tx',{
        dojo_data  => $dojo_data,
        owner_data => $owner,
        joined     => $dojo_data->joined($user_id),
    });
}

sub create {
    my ($class, $c) = @_;
    my $user_id = $c->session_get();

    my $dojo_id = Grammatch::Model::Dojo->create($user_id);
    return $c->redirect('/') unless $dojo_id;
    return $c->redirect("/dojo/$dojo_id");
}

sub join {
    my ($class, $c, $param) = @_;
    my $dojo_id = $param->{id};
    my $user_id = $c->session_get();

    my $retval = Grammatch::Model::Dojo->join($user_id, $dojo_id);
    return $c->redirect('/') unless $retval;
    return $c->redirect("/dojo/$dojo_id");
}

1;
