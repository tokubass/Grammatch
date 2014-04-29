package Grammatch::Web::C::Comment;
use strict;
use warnings;
use utf8;
use Grammatch::App::Comment;
use Time::Piece;

sub event_post {
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
   
    Grammatch::App::Comment->event_post(
        event_id => $path_param->{event_id}, 
        user_id  => $logged_user_id,
        comment  => $c->req->param('comment'),
    );
    return $c->redirect('/event/' . $path_param->{event_id});
}

sub dojo_post {
    my ($class, $c, $path_param) = @_;
    my $logged_user_id = $c->session_get();
    return $c->redirect('/') unless $logged_user_id;
   
    Grammatch::App::Comment->dojo_post(
        dojo_id => $path_param->{dojo_id},
        user_id => $logged_user_id,
        comment => $c->req->param('comment'),
    );
    return $c->redirect('/dojo/' . $path_param->{dojo_id});
}

1;
