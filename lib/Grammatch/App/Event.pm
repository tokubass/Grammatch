package Grammatch::App::Event;
use strict;
use warnings;
use Amon2::Declare;   
use Try::Tiny;
use Time::Piece;

sub event {
    my ($class, $event_id, $logged_user_id) = @_;
    my $event_data = c->db->single(event => { event_id => $event_id }) or die;
    
    my $owner_data         = $event_data->owner();
    my $member_list        = $event_data->members();

    return {
        event_data  => $event_data,
        owner_data  => $owner_data,
        dojo_data   => $owner_data->own_dojo,
        member_list => $member_list,
    };
}

sub insert {
    my ($class, $logged_user_id, $params) = @_;

    my $dojo_data = Grammatch::App::Dojo->info_by_user_id($logged_user_id);
    my $event_id;

    my $txn = c->db->txn_scope;
    my $current_time = localtime();
    my $start_time = Time::Piece->strptime($params->{start_time}, "%Y/%m/%d %H:%M");
    try {
        $event_id = c->db->fast_insert(event => {
            user_id       => $logged_user_id,
            dojo_id       => $dojo_data->dojo_id,
            event_name    => $params->{event_name},
            pref_id       => $params->{pref_id},
            place         => $params->{place},
            reward        => $params->{reward},
            period        => $params->{period},
            start_time    => $start_time,
            created_at    => $current_time,
            updated_at    => $current_time,
            event_summary => $params->{event_summary},
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return $event_id;
}

1;
