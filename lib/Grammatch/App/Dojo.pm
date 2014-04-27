package Grammatch::App::Dojo;
use strict;
use warnings;
use Amon2::Declare;   
use Try::Tiny;
use Time::Piece;

sub dojo {
    my ($class, $dojo_id, $logged_user_id) = @_;
    my $dojo_data;

    if ($dojo_id) {
        $dojo_data = c->db->single(dojo => { dojo_id => $dojo_id }) or die;
    } else {
        $dojo_data = c->db->single(dojo => { user_id => $logged_user_id });
        return unless $dojo_data;
    } 

    my $owner_data         = $dojo_data->owner();
    my $member_list        = $dojo_data->members();
    my $logged_user_status = defined $logged_user_id
        ? $dojo_data->user_status($logged_user_id)
        : undef;

    return {
        dojo_data          => $dojo_data,
        owner_data         => $owner_data,
        member_list        => $member_list,
        logged_user_status => $logged_user_status,
    }
}

sub join {
    my ($class, $dojo_id, $logged_user_id) = @_;
    my $txn = c->db->txn_scope;
    my $current_time = localtime();
    try {
        c->db->insert(user_dojo_map => {
            user_id    => $logged_user_id,
            dojo_id    => $dojo_id,
            status     => 2, # 申請中
            created_at => $current_time,
            updated_at => $current_time,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub dropout {
    my ($class, $dojo_id, $logged_user_id) = @_;
    my $user_dojo_map = c->db->single(user_dojo_map => { dojo_id => $dojo_id, user_id => $logged_user_id }) or die;

    my $txn = c->db->txn_scope;
    try {
        if ($user_dojo_map->status == 1 || $user_dojo_map->status == 4) {
            $user_dojo_map->dojo->dropout; 
        }  
        $user_dojo_map->delete;
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub motion {
    my ($class, $logged_user_id) = @_;
    my $dojo_data = c->db->single(dojo => { user_id => $logged_user_id });

    my $motion_list = $dojo_data->motions;
    return {
        motion_list => $motion_list,
        dojo_data   => $dojo_data,
    };
}

sub accept {
    my ($class, $logged_user_id, $accept_user_id) = @_;
    my $dojo_data = c->db->single(dojo => { user_id => $logged_user_id });

    my $user_dojo_map = c->db->single(user_dojo_map => { dojo_id => $dojo_data->dojo_id, user_id => $accept_user_id }) or die;
    return 0 if $user_dojo_map->status != 2;

    my $txn = c->db->txn_scope;
    my $current_time = localtime();
    try {
        $user_dojo_map->update({status => 1, updated_at => $current_time});
        $user_dojo_map->dojo->accept();
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub create {
    my ($class, $logged_user_id) = @_;
    my $user_data = c->db->single(user => { user_id => $logged_user_id });
    return 0 if $user_data->allow_create_dojo != 1 || $user_data->dojo_id != 0;

    my $dojo_id;
    my $txn = c->db->txn_scope;
    my $current_time = localtime();
    try {
        $dojo_id = c->db->fast_insert(dojo => {
            dojo_name => $user_data->user_name,
            user_id   => $user_data->user_id,
            created_at => $current_time,
            updated_at => $current_time,
        });
        c->db->fast_insert(user_dojo_map => {
            user_id    => $user_data->user_id,
            dojo_id    => $dojo_id,
            status     => 3, # 師範
            created_at => $current_time,
            updated_at => $current_time,
        });
        $user_data->created_dojo($dojo_id);
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };

    return $dojo_id;
}

1;
