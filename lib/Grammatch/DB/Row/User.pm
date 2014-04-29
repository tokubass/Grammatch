package Grammatch::DB::Row::User;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Amon2::Declare;
use Try::Tiny;
use Time::Piece;

sub login {
    my ($self, $twitter_screen_name) = @_;

    my $txn = c->db->txn_scope;
    try {
        $self->update({
            last_logged_at      => scalar localtime,
            twitter_screen_name => $twitter_screen_name,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub dojo {
    my $self = shift;
    return c->db->single(dojo => { dojo_id => $self->dojo_id }) || undef;
}

sub joined_dojo {
    my $self = shift;
    return scalar c->db->search_by_sql(q{
        SELECT *
        FROM   user_dojo_map 
        JOIN   dojo 
        ON     user_dojo_map.dojo_id = dojo.dojo_id
        WHERE  user_dojo_map.user_id = ?
    }, [ $self->user_id ],
    );
}

sub create_dojo { # OK!
    my ($self, $dojo_id) = @_;
    my $txn = c->db->txn_scope;
    try {
        $self->update({
            allow_create_dojo => 0,
            dojo_id           => $dojo_id,
            updated_at        => scalar localtime,
        });
        c->db->fast_insert(user_dojo_map => {
            user_id    => $self->user_id,
            dojo_id    => $dojo_id,
            status     => 3, # 師範
            updated_at => scalar localtime,
            created_at => scalar localtime,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub edit {
    my ($self, $params) = @_;

    my $txn = c->db->txn_scope;
    try {
        $self->update({
            user_name    => $params->{user_name},
            pref_id      => $params->{pref_id},
            user_summary => $params->{user_summary},
            updated_at   => scalar localtime,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

1;
