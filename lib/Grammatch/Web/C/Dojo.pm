package Grammatch::Web::C::Dojo;
use strict;
use warnings;
use Grammatch::App::Dojo;

sub dojo {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();

    my $data = Grammatch::App::Dojo->dojo($param->{id}, $logged_user_id);
    return $c->render('dojo/dojo.tx', $data);
}

sub join {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();

    Grammatch::App::Dojo->join($param->{id}, $logged_user_id); 
    return $c->redirect('/dojo/' . $param->{id});
}

sub dropout {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Dojo->dropout($param->{id}, $logged_user_id); 
    return $c->redirect('/dojo/' . $param->{id});
}

sub motion {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $motion_list = Grammatch::App::Dojo->motion($param->{id}, $logged_user_id); 
    if ($motion_list) {
        return $c->render('dojo/motion.tx', $motion_list); 
    } else {
        return $c->redirect('/dojo/' . $param->{id}); 
    }
}

sub accept {
    my ($class, $c, $param) = @_;
    my $dojo_id = $param->{id};
    my $accept_user_id = $c->req->param('user_id');

    Grammatch::App::Dojo->accept($dojo_id, $accept_user_id);

    return $c->redirect("/dojo/$dojo_id/motion");
}

#sub create {
#    my ($class, $c) = @_;
#    my $user_id = $c->session_get();
#
#    my $dojo_id = Grammatch::Model::Dojo->create($user_id);
#    return $c->redirect('/') unless $dojo_id;
#    $c->session->set('dojo_id' => $dojo_id);
#    return $c->redirect("/dojo/$dojo_id");
#}

1;
