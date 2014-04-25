package Grammatch::Model::Dojo;
use strict;
use warnings;
use Amon2::Declare;
use Try::Tiny;
use Time::Piece;
use Grammatch::Model::User;

sub dojo {
    my ($class, $dojo_id) = @_;
    die "Error" unless $dojo_id;

    return c->db->single('dojo' => { dojo_id => $dojo_id }) or die "dojo $dojo_id: not found"; 
}

sub join {
    my ($class, $user_id, $dojo_data) = @_;
    die "Error" unless $user_id;
    die "Error" unless $dojo_data;
    
    my $db = c->db;

    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $db->fast_insert('user_dojo_map' => {
            user_id    => $user_id,
            dojo_id    => $dojo_data->dojo_id,
            status     => 2,
            created_at => $current_time,
            updated_at => $current_time,
        });    
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub create {
    my ($class, $user_id) = @_;
    die "Error" unless $user_id;

    my $db = c->db;
    
    my $user = Grammatch::Model::User->user($user_id);
    return undef if $user->dojo_id != 0; # he have dojo
    return undef if $user->allow_create_dojo != 1; # he can't create dojo

    my $dojo_id;
    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $dojo_id = $db->fast_insert('dojo' => {
            dojo_name  => $user->user_name,
            user_id    => $user->user_id,
            created_at => $current_time,
            updated_at => $current_time,
        });    
        $user->update({ allow_create_dojo => 0, dojo_id => $dojo_id });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };

    return $dojo_id;
}

1;

