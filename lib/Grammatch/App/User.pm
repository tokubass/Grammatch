package Grammatch::App::User;
use strict;
use warnings;
use utf8;
use Amon2::Declare;   

sub user {
    my ($class, $user_id) = @_;
    my $user_data = c->db->single(user => { user_id => $user_id }) or die;
   
    my $dojo_data = $user_data->own_dojo();
    my $dojo_list = $user_data->related_dojos();

    return {
        user_data => $user_data,
        dojo_data => $dojo_data,
        dojo_list => $dojo_list,
    }; 
}

sub profile {
    my ($class, $user_id) = @_;
    c->db->single(user => { user_id => $user_id }) or die;
}

sub commit {
    my ($class, $user_id, $params) = @_;
    my $user_data = c->db->single(user => { user_id => $user_id }) or die;
    $user_data->commit($params);
}

1;
