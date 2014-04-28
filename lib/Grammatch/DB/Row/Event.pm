package Grammatch::DB::Row::Event;
use strict;
use warnings;
use parent 'Teng::Row';
use Try::Tiny;
use Time::Piece;

sub owner {
    my $self = shift;
    $self->{teng}->single(user => { user_id => $self->user_id });
}

sub members {
    my $self = shift;
    $self->{teng}->search_by_sql(q{
        SELECT * FROM user_event_map JOIN user ON user_event_map.user_id = user.user_id
        WHERE user_event_map.event_id = ? AND user_event_map.status = 1
    }, [ $self->event_id ],
    );
}

1;
