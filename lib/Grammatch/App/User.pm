package Grammatch::App::User;
use strict;
use warnings;
use utf8;
use Amon2::Declare;   
use Smart::Args;

sub user {
    args
        my $class,
        my $user_id => 'Int';

    my $user = c->db->single(user => { user_id => $user_id }) or die;
    return {
        user       => $user,
        dojo       => $user->dojo,
        dojo_list  => $user->joined_dojo,
        event_list => $user->joined_event,
    }; 
}

sub edit_form {
    args
        my $class,
        my $user_id => 'Int';

    return c->db->single(user => { user_id => $user_id }) or die;
}

sub edit {
    args
        my $class,
        my $user_id => 'Int',
        my $params  => 'HashRef';

    my $user = c->db->single(user => { user_id => $user_id }) or die;
    $user->edit($params);
}

1;
