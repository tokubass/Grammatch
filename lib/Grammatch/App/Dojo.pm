package Grammatch::App::Dojo;
use strict;
use warnings;
use utf8;
use Amon2::Declare;   
use Try::Tiny;
use Time::Piece;
use SQL::Maker::Condition;
use Smart::Args;

sub dojo {
    args 
        my $class,
        my $dojo_id => 'Int',
        my $user_id  => { optional => 1 };

    my $dojo = c->db->single(dojo => { dojo_id => $dojo_id }) or die;
    return {
        dojo         => $dojo,
        owner        => $dojo->owner,
        participants => $dojo->participants,
        event        => $dojo->newest_event,
        comments     => $dojo->comments,
        user_status  => $dojo->user_status($user_id),
    }
}

sub dojo_root {
    args 
        my $class,
        my $user_id => 'Int';

    my $dojo = c->db->single(dojo => { user_id => $user_id });
    return defined $dojo ? $dojo->dojo_id : undef;
}

sub edit_form {
    args
        my $class,
        my $user_id => 'Int';

    return c->db->single(dojo => { user_id => $user_id }) or die;
}    

sub edit {
    args 
        my $class,
        my $user_id => 'Int',
        my $params  => 'HashRef';

    my $dojo = c->db->single(dojo => { user_id => $user_id }) or die;
    $dojo->edit($params);
    return $dojo->dojo_id;
}

sub request {
    args 
        my $class,
        my $user_id => 'Int',
        my $dojo_id => 'Int';

    my $user_dojo_map = c->db->single(user_dojo_map => { user_id => $user_id, dojo_id => $dojo_id }); 
    return if $user_dojo_map && $user_dojo_map->status != 0;
   
    my $txn = c->db->txn_scope;
    try {
        c->db->insert(user_dojo_map => {
            user_id    => $user_id,
            dojo_id    => $dojo_id,
            status     => 2, # 申請中
            created_at => scalar localtime,
            updated_at => scalar localtime,
        });    
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub dropout {
    args 
        my $class,
        my $user_id => 'Int',
        my $dojo_id => 'Int';

    my $user_dojo_map = c->db->single(user_dojo_map => { user_id => $user_id, dojo_id => $dojo_id }) or die; 
    $user_dojo_map->dropout;
    if ($user_dojo_map->status == 1) {
        $user_dojo_map->dojo->dropout;
    } 
}

sub request_list {
    args 
        my $class,
        my $user_id => 'Int';

    my $dojo = c->db->single(dojo => { user_id => $user_id }) or die;
    return {
        requests => $dojo->requests,
        dojo     => $dojo,
    }
}

sub accept {
    args 
        my $class,
        my $accept_user_id => 'Int',
        my $user_id        => 'Int';

    my $dojo = c->db->single(dojo => { user_id => $user_id }) or die;
    my $user_dojo_map = c->db->single(user_dojo_map => { user_id => $accept_user_id, dojo_id => $dojo->dojo_id });
    return unless $user_dojo_map;

    if ($user_dojo_map->status == 2) {
        $user_dojo_map->accept;
        $dojo->accept;
    }
}

sub create {
    args 
        my $class,
        my $user_id => 'Int';

    my $user = c->db->single(user => { user_id => $user_id }) or die;
    return 0 if $user->allow_create_dojo != 1 || $user->dojo_id != 0;

    my $dojo_id;
    my $txn = c->db->txn_scope;
    try {
        $dojo_id = c->db->fast_insert(dojo => {
            dojo_name  => $user->user_name,
            user_id    => $user->user_id,
            created_at => scalar localtime,
            updated_at => scalar localtime,
        });
        $user->create_dojo($dojo_id);
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return $dojo_id;
}

sub events {
    args 
        my $class,
        my $dojo_id => 'Int';
    
    my $dojo = c->db->single(dojo => { dojo_id => $dojo_id }) or die;
    return {
        dojo   => $dojo, 
        events => $dojo->events,
    };
}

1;
