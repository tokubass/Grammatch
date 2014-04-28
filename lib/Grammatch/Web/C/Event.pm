package Grammatch::Web::C::Event;
use strict;
use warnings;
use Grammatch::App::Event;
use Grammatch::App::Dojo;
use Time::Piece;

sub event {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    my $data = Grammatch::App::Event->event($param->{id}, $logged_user_id);

    return $c->redirect('/') unless $data; 
    return $c->render('event/event.tx', $data);
}

sub create {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
    
    my $dojo_data = Grammatch::App::Dojo->info_by_user_id($logged_user_id);
    $c->render('/event/edit.tx', { event_data => { pref_id => $dojo_data->pref_id }});
}

sub create_commit {
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $params = $c->req->parameters()->as_hashref;
    $c->form(
        event_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        place      => [qw/ NOT_BLANK /, [qw/ LENGTH 1 50 /]],
        reward     => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        start_time => [qw/ NOT_BLANK /, [qw/ REGEX /, qr!\d{4}/\d{2}/\d{2}\s+\d{2}:\d{2}!]],
        period     => [qw/ NOT_BLANK /, [qw/ REGEX /, qr!\d+!]],
    );
    $params->{start_time} = Time::Piece->strptime($params->{start_time}, "%Y/%m/%d %H:%M");
    if ($c->form->has_error) {
        my $errors;
        return $c->render('/event/edit.tx', { event_data => $params, form => $c->form });
    }

    $c->log->info($params);
    my $event_id = Grammatch::App::Event->insert($logged_user_id, $params);
    return $c->redirect('/event/' . $event_id);
}

sub edit {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
    
    my $event_data = Grammatch::App::Event->info($param->{id});
    return $c->redirect('/event/' . $param->{id}) if $event_data->user_id != $logged_user_id;

    $c->render('/event/edit.tx', { event_data => $event_data });
}

sub update {
    my ($class, $c, $param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $params = $c->req->parameters()->as_hashref;
    $c->form(
        event_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        place      => [qw/ NOT_BLANK /, [qw/ LENGTH 1 50 /]],
        reward     => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        start_time => [qw/ NOT_BLANK /, [qw/ REGEX /, qr!\d{4}/\d{2}/\d{2}\s+\d{2}:\d{2}!]],
        period     => [qw/ NOT_BLANK /, [qw/ REGEX /, qr!\d+!]],
    );
    $params->{start_time} = Time::Piece->strptime($params->{start_time}, "%Y/%m/%d %H:%M");
    $params->{event_id} = $param->{id};
    if ($c->form->has_error) {
        my $errors;
        return $c->render('/event/edit.tx', { event_data => $params, form => $c->form });
    }

    $c->log->info($params);
    Grammatch::App::Event->update($params);
    return $c->redirect('/event/' . $param->{id});

}

1;
