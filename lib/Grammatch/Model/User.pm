package Grammatch::Model::User;
use strict;
use warnings;
use Amon2::Declare;

sub user {
    my ($class, $user_id) = @_;
    return undef unless $user_id;
    return c->db->single('user' => { user_id => $user_id }) || undef;
}

1;

