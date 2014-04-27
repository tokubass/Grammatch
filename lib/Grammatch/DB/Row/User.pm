package Grammatch::DB::Row::User;
use strict;
use warnings;
use parent 'Teng::Row';
use Try::Tiny;
use Time::Piece;

sub own_dojo {
    my $self = shift;
    $self->{teng}->single(dojo => { dojo_id => $self->dojo_id });
}

sub related_dojos {
    my $self = shift;
    $self->{teng}->search_by_sql(
        'SELECT * FROM user_dojo_map JOIN dojo ON user_dojo_map.dojo_id = dojo.dojo_id WHERE user_dojo_map.user_id = ?',
        [ $self->user_id ],
    );
}

sub login {
    my ($self, $twitter_screen_name) = @_;

    my $txn = $self->{teng}->txn_scope;
    my $current_time = localtime();
    try {
        $self->update({
            last_logged_at      => $current_time,
            twitter_screen_name => $twitter_screen_name,
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub created_dojo {
    my ($self, $dojo_id) = @_;
    
    my $txn = $self->{teng}->txn_scope;
    try {
        $self->update({ allow_create_dojo => 0, dojo_id => $dojo_id });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub commit {
    my ($self, $params) = @_;

    my $txn = $self->{teng}->txn_scope;
    try {
        $self->update({
            user_name    => $params->{user_name} || 'e',
            pref_id      => $params->{pref_id},
            user_summary => $params->{user_summary},
        });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

1;
