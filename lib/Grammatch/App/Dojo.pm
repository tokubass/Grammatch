package Grammatch::App::Dojo;
use strict;
use warnings;
use Amon2::Declare;   
use Try::Tiny;

sub dojo {
    my ($class, $dojo_id, $logged_user_id) = @_;
    my $dojo_data = c->db->single(dojo => { dojo_id => $dojo_id }) or die;

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

1;
