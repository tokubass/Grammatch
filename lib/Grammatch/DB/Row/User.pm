package Grammatch::DB::Row::User;
use strict;
use warnings;

use parent 'Teng::Row';

sub dojo {
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

1;
