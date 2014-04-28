package Grammatch::Web::C::Event;
use strict;
use warnings;
use Grammatch::App::Event;

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

    my $params = $c->req->parameters();
    $c->form(
        event_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        place      => [qw/ NOT_BLANK /, [qw/ LENGTH 1 50 /]],
        reward     => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        start_time => [qw/ NOT_BLANK /, [qw/ REGEX /, qr!\d{4}/\d{2}/\d{2} \d{2}:\d{2}!]],
        period     => [qw/ NOT_BLANK /, [qw/ REGEX /, qr!\d+!]],
    );
    if ($c->form->has_error) {
        my $errors;
        return $c->render('/event/edit.tx', { event_data => $params->as_hashref, form => $c->form });
    }

    my $event_id = Grammatch::App::Event->insert($logged_user_id, $params);
    return $c->redirect('/event/' . $event_id);
}

1;
