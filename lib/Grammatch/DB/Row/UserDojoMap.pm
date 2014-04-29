package Grammatch::DB::Row::UserDojoMap;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Amon2::Declare;
use Try::Tiny;
use Time::Piece;

sub dojo { # OK!
    my ($self) = @_;
    c->db->single(dojo => { dojo_id => $self->dojo_id });
}

sub dropout { # OK!
    my ($self, $user_id) = @_;
    
    my $txn = c->db->txn_scope;
    try {
        $self->delete;
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

sub accept { # OK!
    my ($self, $user_id) = @_;
    
    my $txn = c->db->txn_scope;
    try {
        $self->update({ status => 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
}

1;
