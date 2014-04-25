package Grammatch::DB::Row::Dojo;
use strict;
use warnings;

use parent 'Teng::Row';

sub owner {
    my $self = shift;
    $self->{teng}->single(user => { user_id => $self->user_id });
}

sub joined {
    my ($self, $user_id) = @_;
    return undef unless $user_id;

    my $result = $self->{teng}->single(user_dojo_map => {
        user_id => $user_id,
        dojo_id => $self->dojo_id,
    });
    return defined $result ? $result->status : 0;
}

1;
