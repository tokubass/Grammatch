package Grammatch::App::Dojo;
use strict;
use warnings;
use Amon2::Declare;   

sub dojo {
    my ($class, $dojo_id, $logged_user_id) = @_;
    my $dojo_data = c->db->single(dojo => { dojo_id => $dojo_id }) or die "dojo id '$dojo_id' : not found.";

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

1;
