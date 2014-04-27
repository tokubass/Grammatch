package Grammatch::DB::Row::UserDojoMap;
use strict;
use warnings;
use parent 'Teng::Row';
use Try::Tiny;

sub dojo {
    my ($self) = @_;
    $self->{teng}->single(dojo => { dojo_id => $self->dojo_id });
}

1;
