package Grammatch::App::Event;
use strict;
use warnings;
use utf8;
use Amon2::Declare;   
use Try::Tiny;
use Time::Piece;
use Smart::Args;

sub event { # OK!
    args 
        my $class,
        my $event_id => 'Int',
        my $user_id  => { optional => 1 };
   
    my $event = c->db->single(event => { event_id => $event_id }) or die;
    return {
        event         => $event,
        owner         => $event->owner,
        dojo          => $event->dojo,
        participants  => $event->participants,
        user_status   => $event->user_status($user_id),
        finished      => $event->start_at <= localtime() ? 1 : 0,
        comments      => $event->comments,
    };
}

sub create_form { # OK!
    args
        my $class,
        my $user_id => 'Int';
    
    my $user = c->db->single(user => { user_id => $user_id }) or die;
    die unless $user->dojo_id;
    return $user;
}

sub create { # OK!
    args
        my $class,
        my $user_id => 'Int',
        my $params  => 'HashRef';
 
    my $user = c->db->single(user => { user_id => $user_id });
    die unless $user->dojo_id;
    my $event_id;
    my $txn = c->db->txn_scope;
    try {
        $event_id = c->db->fast_insert(event => {
            user_id       => $user_id,
            dojo_id       => $user->dojo_id,
            event_name    => $params->{event_name},
            pref_id       => $params->{pref_id},
            place         => $params->{place},
            reward        => $params->{reward},
            period        => $params->{period},
            start_at      => $params->{start_at} - 60 * 60 * 9, # FIXME
            updated_at    => scalar localtime,
            created_at    => scalar localtime,
            event_summary => $params->{event_summary},
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return $event_id;
}

sub edit_form { # OK!
    args 
        my $class,
        my $event_id => 'Int',
        my $user_id  => 'Int';

    my $event = c->db->single(event => { event_id => $event_id }) or die;
    die if $event->user_id != $user_id;
    return $event;
}

sub edit { # OK!
    args
        my $class,
        my $user_id => 'Int',
        my $params  => 'HashRef';

    my $event_id = $params->{event_id} ;
    my $event = c->db->single(event => { event_id => $event_id }) or die;
    die if $event->user_id != $user_id; 
    
    $event->edit($params)
}

sub join { # OK!
    args 
        my $class,
        my $event_id => 'Int',
        my $user_id  => 'Int';
    
    my $event = c->db->single(event => { event_id => $event_id }) or die; 
    return if $event->is_vacancy != 1; 
    die if $event->user_id == $user_id;

    $event->join($user_id);
}

sub resign { # OK!
    args 
        my $class,
        my $event_id => 'Int',
        my $user_id  => 'Int';
    
    my $event = c->db->single(event => { event_id => $event_id }) or die; 
    die if $event->user_status($user_id) != 1;
  
    $event->resign($user_id);
}

1;
