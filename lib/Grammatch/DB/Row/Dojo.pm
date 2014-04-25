package Grammatch::DB::Row::Dojo;
use strict;
use warnings;

use parent 'Teng::Row';

sub owner {
    my $self = shift;
    $self->{teng}->single(user => { user_id => $self->user_id });
}

sub joined_user {
    my $self = shift;
    my $user_id = shift or die;
    $self->{teng}->single(user_dojo_map => { dojo_id => $self->dojo_id, user_id => $user_id }) || 0;
}


1;
