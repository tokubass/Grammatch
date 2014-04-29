package Grammatch::Web::C::Dojo;
use strict;
use warnings;
use utf8;
use Grammatch::App::Dojo;

sub dojo {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();

    my $data = Grammatch::App::Dojo->dojo($param->{id}, $logged_user_id);
    $c->log->info($data->{event_list});
    return $c->redirect('/') unless $data;
    return $c->render('dojo/dojo.tx', $data);
}

sub dojo_root {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $data = Grammatch::App::Dojo->dojo(undef, $logged_user_id);
    return $c->redirect('/') unless $data;
    return $c->render('dojo/dojo.tx', $data);
}

sub join {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

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
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $motion_list = Grammatch::App::Dojo->motion($logged_user_id); 
    if ($motion_list) {
        return $c->render('dojo/motion.tx', $motion_list); 
    } else {
        return $c->redirect('/dojo'); 
    }
}

sub accept {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    my $accept_user_id = $c->req->param('user_id');
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Dojo->accept($logged_user_id, $accept_user_id);
    return $c->redirect('/dojo/motion');
}

sub create {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
    
    my $dojo_id = Grammatch::App::Dojo->create($logged_user_id);
    return $c->redirect('/') unless $dojo_id;
    
    $c->session->set('dojo_id' => $dojo_id);
    return $c->redirect("/dojo/$dojo_id");
}

sub edit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $dojo_data = Grammatch::App::Dojo->info_by_user_id($logged_user_id);
    return $c->render('dojo/edit.tx', { dojo_data => $dojo_data });
}

sub commit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $params = $c->req->parameters();
    $c->form(
        dojo_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]], 
    );
    if ($c->form->has_error) {
        my $errors;
        return $c->render('dojo/edit.tx', { dojo_data => $params->as_hashref, form => $c->form });
    }

    Grammatch::App::Dojo->commit($logged_user_id, $params);
    return $c->redirect('/dojo');
}

1;
