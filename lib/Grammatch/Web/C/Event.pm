package Grammatch::Web::C::Event;
use strict;
use warnings;
use utf8;
use Grammatch::App::Event;
use Time::Piece;

sub event { # OK!
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    
    my $data = Grammatch::App::Event->event(
        event_id => $path_param->{event_id}, 
        user_id  => $logged_user_id
    );
    return $c->render('event/event.tx', $data);
}

# require login
sub create_form { # OK!
    my ($class, $c) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    my $user = Grammatch::App::Event->create_form(user_id => $logged_user_id);

    $c->render('/event/edit.tx', { event => {
        event_pref_id => $user->pref_id, # FIXME -> user_pref_id ?
        start_at      => scalar localtime, 
    }});
}

sub create { # OK!
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    $c->form(
        event_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        place      => [qw/ NOT_BLANK /, [qw/ LENGTH 1 50 /]],
        reward     => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        start_at   => [qw/ NOT_BLANK /, ['DATETIME_STRPTIME', '%Y/%m/%d %H:%M']],
        period     => [qw/ NOT_BLANK INT /],
    );
    my $params = $c->req->parameters()->as_hashref;
    $params->{start_at} = $params->{start_at}
        ? Time::Piece->strptime($params->{start_at}, "%Y/%m/%d %H:%M")
        : scalar localtime;
    return $c->render('/event/edit.tx', { event => $params, form => $c->form }) if $c->form->has_error;

    my $event_id = Grammatch::App::Event->create(params => $params, user_id => $logged_user_id);
    return $c->redirect('/event/' . $event_id);
}

sub edit_form { # OK!
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
    
    my $event = Grammatch::App::Event->edit_form(
        event_id => $path_param->{event_id},
        user_id  => $logged_user_id,
    );

    $c->render('/event/edit.tx', { event => $event });
}

sub edit { # OK!
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    $c->form(
        event_name => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        place      => [qw/ NOT_BLANK /, [qw/ LENGTH 1 50 /]],
        reward     => [qw/ NOT_BLANK /, [qw/ LENGTH 1 20 /]],
        start_at   => [qw/ NOT_BLANK /, ['DATETIME_STRPTIME', '%Y/%m/%d %H:%M']],
        period     => [qw/ NOT_BLANK INT /],
    );
    my $params = $c->req->parameters()->as_hashref;
    $params->{start_at} = $params->{start_at}
        ? Time::Piece->strptime($params->{start_at}, "%Y/%m/%d %H:%M")
        : scalar localtime;
    $params->{event_id} = $path_param->{event_id};
    return $c->render('/event/edit.tx', { event => $params, form => $c->form }) if $c->form->has_error;

    Grammatch::App::Event->edit(params => $params, user_id => $logged_user_id);
    return $c->redirect('/event/' . $path_param->{event_id});
}

sub join { # OK!
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Event->join(
        event_id => $path_param->{event_id},
        user_id  => $logged_user_id
    );
    return $c->redirect('/event/' . $path_param->{event_id});
}

sub resign { # OK!
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;

    Grammatch::App::Event->resign(
        event_id => $path_param->{event_id},
        user_id  => $logged_user_id
    );
    return $c->redirect('/event/' . $path_param->{event_id});
}

sub comment {
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
   
    Grammatch::App::Event->comment(
        event_id => $path_param->{event_id}, 
        user_id  => $logged_user_id,
        comment  => $c->req->param('comment'),
    );
    return $c->redirect('/event/' . $path_param->{event_id});
}

1;
