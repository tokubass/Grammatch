package Grammatch::DB::Row::Event;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Try::Tiny;
use Time::Piece;
use Data::Page::NoTotalEntries;

sub owner { # OK!
    my $self = shift;
    return $self->handle->single(user => { user_id => $self->user_id }) or die;
}

sub dojo { # OK!
    my $self = shift;
    return $self->handle->single(dojo => { dojo_id => $self->dojo_id }) or die;
}

sub participants { # OK!
    my $self = shift;
    return scalar $self->handle->search_by_sql(q{
        SELECT   *
        FROM     user_event_map
        JOIN     user
        ON       user_event_map.user_id  = user.user_id
        WHERE    user_event_map.event_id = ?
          AND    user_event_map.status   = 1
        ORDER BY user_event_map.id DESC
    }, [ $self->event_id ],
    );
}

sub user_status { # OK!
    my ($self, $user_id) = @_;
    return 0 unless $user_id;
    my $user_event_map = $self->handle->single(user_event_map => {
        user_id => $user_id, 
        event_id => $self->event_id
    });
    return defined $user_event_map ? $user_event_map->status : 0;
}

sub is_vacancy { # OK!
    my ($self) = @_;
    return $self->event_member < c->config->{event_limit} ? 1 : 0;
}

sub join { # OK!
    my ($self, $user_id) = @_;
    my $txn = $self->handle->txn_scope;
    try {
        $self->handle->fast_insert(user_event_map => {
            event_id   => $self->event_id,
            user_id    => $user_id,
            created_at => scalar localtime,
            updated_at => scalar localtime,
            status     => 1,
        }); 
        $self->update({ event_member => $self->event_member + 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub resign { # OK!
    my ($self, $user_id) = @_;
    my $txn = $self->handle->txn_scope;
    try {
        $self->handle->delete(user_event_map => {
            event_id   => $self->event_id,
            user_id    => $user_id,
        }); 
        $self->update({ event_member => $self->event_member - 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub edit { # OK!
    my ($self, $params) = @_;
    my $txn = $self->handle->txn_scope;
    try {
        $self->update({
            event_name    => $params->{event_name},
            pref_id       => $params->{pref_id},
            place         => $params->{place},
            reward        => $params->{reward},
            period        => $params->{period},
            start_at      => $params->{start_at} - 60 * 60 * 9, # FIXME
            updated_at    => scalar localtime,
            event_summary => $params->{event_summary},
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub comments { # OK!
    my $self = shift;
    return scalar $self->handle->search_by_sql(q{
        SELECT   *, event_comment.created_at as posted_at
        FROM     event_comment 
        JOIN     user
        ON       event_comment.user_id  = user.user_id
        WHERE    event_comment.event_id = ?
        ORDER BY event_comment.id DESC
    }, [ $self->event_id ],
    );
}

1;
