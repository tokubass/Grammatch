package Grammatch::Model::Login;
use strict;
use warnings;
use Try::Tiny;
use Time::Piece;
use Amon2::Declare;

sub login {
    my ($class, $twitter_user_id) = @_;
    my $db = c->db;

    my $user = $db->single('user' => {
        twitter_user_id => $twitter_user_id, 
    });
    return undef unless $user;

    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $user->update(
            { last_logged_at => $current_time },
            { user_id        => $user->user_id }
        ); 
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return $user;
}

sub entry {
    my ($class, $twitter_user_id, $twitter_screen_name) = @_;
    my $db = c->db;

    my $user;
    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $user = $db->insert('user' => { 
            user_name           => $twitter_screen_name,
            twitter_screen_name => $twitter_screen_name,
            twitter_user_id     => $twitter_user_id,
            created_at          => $current_time,
            updated_at          => $current_time,
            last_logged_at      => $current_time,
        }); 
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };

    return $user;
}

1;

