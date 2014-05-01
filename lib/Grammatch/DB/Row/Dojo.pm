package Grammatch::DB::Row::Dojo;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Try::Tiny;
use Time::Piece;

sub owner { # OK!
    my $self = shift;
    return $self->{teng}->single(user => { user_id => $self->user_id });
}

sub participants { # OK!
    my $self = shift;
    return scalar $self->handle->search_by_sql(q{
        SELECT   *
        FROM     user_dojo_map
        JOIN     user 
        ON       user_dojo_map.user_id = user.user_id
        WHERE    user_dojo_map.dojo_id = ? 
          AND    user_dojo_map.status = 1
        ORDER BY user_dojo_map.id DESC
    }, [ $self->dojo_id ],
    );
}

sub user_status { # OK!
    my ($self, $user_id) = @_;
    return 0 unless $user_id;
    my $user_dojo_map = $self->handle->single(user_dojo_map => {
        user_id  => $user_id,
        dojo_id  => $self->dojo_id,
    });
    return defined $user_dojo_map ? $user_dojo_map->status : 0;
}

sub newest_event { # OK!
    my $self = shift;
    return $self->handle->single(event => {
        dojo_id  => $self->dojo_id,
        start_at => { '>' => localtime->epoch },
    }, {
        order_by => 'start_at',
    });
}

sub edit { # OK!
    my ($self, $params) = @_;
    my $txn = $self->handle->txn_scope;
    try {
        $self->update({
            dojo_name    => $params->{dojo_name},
            pref_id      => $params->{pref_id},
            updated_at   => scalar localtime,
            dojo_summary => $params->{dojo_summary},
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
        SELECT   *, dojo_comment.created_at as posted_at
        FROM     dojo_comment 
        JOIN     user
        ON       dojo_comment.user_id  = user.user_id
        WHERE    dojo_comment.dojo_id = ?
        ORDER BY dojo_comment.id DESC
    }, [ $self->dojo_id ],
    );
}

sub dropout { # OK!
    my ($self, $dojo_id) = @_;
    my $txn = $self->handle->txn_scope;
    try {
        $self->update({ dojo_member => $self->dojo_member - 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub requests { # OK!
    my $self = shift;
    return scalar $self->handle->search_by_sql(q{
        SELECT   * 
        FROM     user_dojo_map 
        JOIN     user 
        ON       user_dojo_map.user_id = user.user_id
        WHERE    user_dojo_map.dojo_id = ? 
          AND    user_dojo_map.status = 2
        ORDER BY user_dojo_map.id DESC
    }, [ $self->dojo_id ],
    );
}

sub accept {
    my ($self, $user_id) = @_;
    
    my $txn = $self->handle->txn_scope;
    try {
        $self->update({
            dojo_member => $self->dojo_member + 1,
            updated_at  => scalar localtime,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub events {
    my $self = shift;
    return scalar $self->handle->search(event => {
        dojo_id  => $self->dojo_id,
        start_at => { '>' => localtime->epoch },
    }, {
        order_by => 'start_at',
    });
}

1;
