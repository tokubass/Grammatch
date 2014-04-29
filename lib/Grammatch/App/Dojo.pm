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
        events       => $dojo->events,
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

#
#sub create {
#    my ($class, $logged_user_id) = @_;
#    my $user_data = c->db->single(user => { user_id => $logged_user_id });
#    return 0 if $user_data->allow_create_dojo != 1 || $user_data->dojo_id != 0;
#
#    my $dojo_id;
#    my $txn = c->db->txn_scope;
#    my $current_time = localtime();
#    try {
#        $dojo_id = c->db->fast_insert(dojo => {
#            dojo_name  => $user_data->user_name,
#            user_id    => $user_data->user_id,
#            created_at => $current_time,
#            updated_at => $current_time,
#        });
#        c->db->fast_insert(user_dojo_map => {
#            user_id    => $user_data->user_id,
#            dojo_id    => $dojo_id,
#            status     => 3, # 師範
#            created_at => $current_time,
#            updated_at => $current_time,
#        });
#        $user_data->created_dojo($dojo_id);
#        $txn->commit;
#    } catch {
#        $txn->rollback;
#        die $_;
#    };
#
#    return $dojo_id;
#}
#
#sub info_by_user_id {
#    my ($class, $user_id) = @_;
#    c->db->single(dojo => { user_id => $user_id }) or die;
#}
#
#sub commit {
#    my ($class, $user_id, $params) = @_;
#    my $dojo_data = c->db->single(dojo => { user_id => $user_id }) or die;
#    $dojo_data->commit($params);
#}

1;
