package Grammatch::Web::C::Dojo;
use strict;
use warnings;
use utf8;
use Grammatch::App::Dojo;

sub dojo {
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();

    my $data = Grammatch::App::Dojo->dojo(
        dojo_id => $path_param->{dojo_id},
        user_id => $logged_user_id
    );
    return $c->render('dojo/dojo.tx', $data);
}

sub event {
    my ($class, $c, $path_param) = @_;
    my $data = Grammatch::App::Dojo->events(
        dojo_id => $path_param->{dojo_id}, 
    );
    return $c->render('dojo/event.tx', $data);
}

# require login
sub dojo_root {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $dojo_id = Grammatch::App::Dojo->dojo_root( user_id => $logged_user_id );
    return $c->redirect('/') unless $dojo_id;
    return $c->redirect('/dojo/' . $dojo_id);
}

sub edit_form {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $dojo = Grammatch::App::Dojo->edit_form( user_id => $logged_user_id );
    return $c->render('dojo/edit.tx', { dojo => $dojo });
}

sub edit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    $c->form(
        dojo_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]], 
    );
    my $params = $c->req->parameters->as_hashref;
    return $c->render('dojo/edit.tx', { dojo => $params, form => $c->form }) if $c->form->has_error;

    my $dojo_id = Grammatch::App::Dojo->edit(
        params => $params,
        user_id => $logged_user_id
    );

    return $c->redirect('/') unless $dojo_id;
    return $c->redirect('/dojo/' . $dojo_id);
}

sub request {
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Dojo->request(
        dojo_id => $path_param->{dojo_id},
        user_id => $logged_user_id
    );
    return $c->redirect('/dojo/' . $path_param->{dojo_id});
}

sub dropout {
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Dojo->dropout(
        dojo_id => $path_param->{dojo_id},
        user_id => $logged_user_id
    ); 
    return $c->redirect('/dojo/' . $path_param->{dojo_id});
}

sub request_list {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $requests = Grammatch::App::Dojo->request_list( user_id => $logged_user_id ); 
    return $c->render('dojo/request.tx', $requests); 
}

sub accept {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    my $accept_user_id = $c->req->param('user_id');
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Dojo->accept(
        user_id        => $logged_user_id,
        accept_user_id => $accept_user_id,
    );
    return $c->redirect('/dojo/request');
}

sub create {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
    
    my $dojo_id = Grammatch::App::Dojo->create( user_id => $logged_user_id );
    return $c->redirect('/') unless $dojo_id;
    
    $c->session->set('dojo_id' => $dojo_id);
    return $c->redirect('/dojo/' . $dojo_id);
}

1;
