package Grammatch::DB::Row::Dojo;
use strict;
use warnings;

use parent 'Teng::Row';

sub owner {
    my $self = shift;
    $self->{teng}->single(user => $self->user_id);
}

1;
