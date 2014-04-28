package Grammatch::App::Event;
use strict;
use warnings;
use Amon2::Declare;   
use Try::Tiny;
use Time::Piece;

sub insert {
    my ($class, $logged_user_id, $params) = @_;

    my $dojo_data = Grammatch::App::Dojo->info_by_user_id($logged_user_id);
    my $event_id;

    my $txn = c->db->txn_scope;
    my $current_time = localtime();
    my $start_time = Time::Piece->strptime($params->{start_time}, "%Y/%m/%d %H:%M");
    try {
        $event_id = c->db->fast_insert(event => {
            user_id    => $logged_user_id,
            dojo_id    => $dojo_data->dojo_id,
            event_name => $params->{event_name},
            place      => $params->{place},
            reward     => $params->{reward},
            period     => $params->{period},
            start_time => $start_time,
            created_at => $current_time,
            updated_at => $current_time,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return $event_id;
}

1;
