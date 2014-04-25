package Grammatch::DB::Row::User;
use strict;
use warnings;

use parent 'Teng::Row';

sub his_dojo {
    my $self = shift;
    $self->{teng}->single(dojo => { dojo_id => $self->dojo_id });
}

1;
