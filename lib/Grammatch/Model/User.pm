package Grammatch::Model::User;
use strict;
use warnings;
use Amon2::Declare;

sub user {
    my ($class, $user_id) = @_;
    return undef unless $user_id;
    return c->db->single('user' => { user_id => $user_id }) || undef;
}

sub dojo_list {
    my ($class, $user_id) = @_;
    return undef unless $user_id; 
    return c->db->search_by_sql(
        'SELECT * FROM user_dojo_map JOIN dojo ON user_dojo_map.dojo_id = dojo.dojo_id WHERE user_dojo_map.user_id = ? AND status = 1',
        [ $user_id ],
    );
}

1;

