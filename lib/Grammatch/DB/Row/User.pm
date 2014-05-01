package Grammatch::DB::Row::User;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Try::Tiny;
use Time::Piece;
use SQL::Maker::Select;

sub login {
    my ($self, $twitter_screen_name) = @_;

    my $txn = $self->handle->txn_scope;
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
    return $self->handle->single(dojo => { dojo_id => $self->dojo_id }) || undef;
}

sub joined_dojo {
    my $self = shift;
    return scalar $self->handle->search_by_sql(q{
        SELECT *
        FROM   user_dojo_map 
        JOIN   dojo 
        ON     user_dojo_map.dojo_id = dojo.dojo_id
        WHERE  user_dojo_map.user_id = ?
        ORDER BY dojo.dojo_id DESC
    }, [ $self->user_id ],
    );
}

sub joined_event { # OK!
    my $self = shift;
    my $stmt = SQL::Maker::Select->new();
    $stmt->add_join(user_event_map => { table => 'event', condition => 'user_event_map.event_id = event.event_id'});
    $stmt->add_join(event => { table => 'dojo', condition => 'event.dojo_id = dojo.dojo_id'});
    $stmt->add_join(dojo => { table => 'user', condition => 'dojo.user_id = user.user_id'});
    $stmt->add_where('user_event_map.user_id' => $self->user_id);
    $stmt->add_where(start_at => { '>' => localtime->epoch });
    $stmt->add_select('*');
    $stmt->add_select('event.pref_id' => 'event_pref_id');
    $stmt->add_order_by('start_at' => 'DESC');

    my $sql  = $stmt->as_sql();
    my @bind = $stmt->bind();
    return scalar $self->handle->search_by_sql($sql, [@bind]);
}

sub create_dojo { # OK!
    my ($self, $dojo_id) = @_;
    my $txn = $self->handle->txn_scope;
    try {
        $self->update({
            allow_create_dojo => 0,
            dojo_id           => $dojo_id,
            updated_at        => scalar localtime,
        });
        $self->handle->fast_insert(user_dojo_map => {
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

    my $txn = $self->handle->txn_scope;
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
