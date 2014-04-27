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

sub dropout {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Dojo->dropout($param->{id}, $logged_user_id); 
    return $c->redirect('/dojo/' . $param->{id});
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
#
#sub join {
#    my ($class, $c, $param) = @_;
#    my $dojo_id = $param->{id};
#    my $user_id = $c->session_get();
#
#    my $retval = Grammatch::Model::Dojo->join($user_id, $dojo_id);
#    return $c->redirect('/') unless $retval;
#    return $c->redirect("/dojo/$dojo_id");
#}
#
#sub pending {
#    my ($class, $c, $param) = @_;
#    my $dojo_id = $param->{id};
#    my $user_id = $c->session_get();
#
#    my $user_list = Grammatch::Model::Dojo->pending($user_id, $dojo_id);
#    return $c->redirect('/') unless $user_list;
#
#    return $c->render('dojo/pending.tx',{
#        user_list => $user_list,
#        dojo_id   => $dojo_id,
#    });
#}
#
#sub accept {
#    my ($class, $c, $param) = @_;
#    my $dojo_id = $param->{id};
#    my $user_id = $c->session_get();
#    my $accept_user_id = $c->req->param('user_id');
#
#    Grammatch::Model::Dojo->accept($user_id, $dojo_id, $accept_user_id);
#
#    return $c->redirect("/dojo/$dojo_id/p");
#}

1;
