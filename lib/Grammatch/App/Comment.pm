package Grammatch::App::Comment;
use strict;
use warnings;
use utf8;
use Amon2::Declare;   
use Try::Tiny;
use Time::Piece;
use Smart::Args;

sub event_post {
    args 
        my $class,
        my $event_id => 'Int',
        my $user_id  => 'Int',
        my $comment;
   
    my $txn = c->db->txn_scope;
    try {
        c->db->fast_insert(event_comment => {
            user_id    => $user_id,
            event_id   => $event_id,
            comment    => $comment,
            updated_at => scalar localtime,
            created_at => scalar localtime,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub dojo_post {
    args 
        my $class,
        my $dojo_id => 'Int',
        my $user_id => 'Int',
        my $comment;
   
    my $txn = c->db->txn_scope;
    try {
        c->db->fast_insert(dojo_comment => {
            user_id    => $user_id,
            dojo_id    => $dojo_id,
            comment    => $comment,
            updated_at => scalar localtime,
            created_at => scalar localtime,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

1;
