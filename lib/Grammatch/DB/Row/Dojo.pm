package Grammatch::DB::Row::Dojo;
use strict;
use warnings;
use parent 'Teng::Row';
use Try::Tiny;

sub owner {
    my $self = shift;
    $self->{teng}->single(user => { user_id => $self->user_id });
}

sub members {
    my $self = shift;
    $self->{teng}->search_by_sql(
        'SELECT * FROM user_dojo_map JOIN user ON user_dojo_map.user_id = user.user_id WHERE user_dojo_map.dojo_id = ? AND user_dojo_map.status = 1',
        [ $self->dojo_id ],
    );
}

sub user_status {
    my ($self, $user_id) = @_;
    $self->{teng}->single(user_dojo_map => { user_id => $user_id, dojo_id => $self->dojo_id });
}

sub motions {
    my $self = shift;
    $self->{teng}->search_by_sql(
        'SELECT * FROM user_dojo_map JOIN user ON user_dojo_map.user_id = user.user_id WHERE user_dojo_map.dojo_id = ? AND user_dojo_map.status = 2',
        [ $self->dojo_id ],
    );
}

sub dropout {
    my ($self, $user_id) = @_;
    
    my $txn = $self->{teng}->txn_scope;
    try {
    $self->update({ dojo_member => $self->dojo_member - 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub accept {
    my ($self, $user_id) = @_;
    
    my $txn = $self->{teng}->txn_scope;
    try {
        $self->update({ dojo_member => $self->dojo_member + 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}
1;
