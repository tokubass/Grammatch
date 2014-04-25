package Grammatch::Model::Dojo;
use strict;
use warnings;
use Amon2::Declare;
use Try::Tiny;
use Time::Piece;
use Grammatch::Model::User;

sub dojo {
    my ($class, $dojo_id) = @_;
    return undef unless $dojo_id; 
    return c->db->single('dojo' => { dojo_id => $dojo_id }) || undef;
}

sub dojo_member {
    my ($class, $dojo_id) = @_;
    return undef unless $dojo_id; 
    return c->db->search_by_sql(
        'SELECT * FROM user_dojo_map JOIN user ON user_dojo_map.user_id = user.user_id WHERE user_dojo_map.dojo_id = ? AND status = 1',
        [ $dojo_id ],
    );
}

sub create {
    my ($class, $user_id) = @_;
    return undef unless $user_id; 
    my $db = c->db;

    my $user_data = Grammatch::Model::User->user($user_id);
    return undef unless $user_data;

    my $dojo_id;
    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $dojo_id = $db->fast_insert('dojo' => {
            dojo_name  => $user_data->user_name,
            user_id    => $user_data->user_id,
            created_at => $current_time,
            updated_at => $current_time,
        });    
        $db->fast_insert('user_dojo_map' => {
            user_id    => $user_data->user_id,
            dojo_id    => $dojo_id,
            status     => 3, # 師範
            created_at => $current_time,
            updated_at => $current_time,
        });
        $user_data->update({ allow_create_dojo => 0, dojo_id => $dojo_id });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };

    return $dojo_id;
}

sub join {
    my ($class, $user_id, $dojo_id) = @_;
    return undef unless $user_id; 
    return undef unless $dojo_id; 
    my $db = c->db;

    my $dojo_data = Grammatch::Model::Dojo->dojo($dojo_id);  
    return undef unless $dojo_data;
    return undef unless $dojo_data->owner($user_id);
    return undef
        if $dojo_data->joined($user_id) != 0 || $dojo_data->dojo_member >= c->config->{dojo_limit};

    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $db->fast_insert('user_dojo_map' => {
            user_id    => $user_id,
            dojo_id    => $dojo_id,
            status     => 2, # 申請中
            created_at => $current_time,
            updated_at => $current_time,
        });    
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return 1;
}

sub pending {
    my ($class, $user_id, $dojo_id) = @_;
    return undef unless $user_id; 
    return undef unless $dojo_id; 

    my $dojo_data = Grammatch::Model::Dojo->dojo($dojo_id);  
    return undef unless $dojo_data;
    my $owner_data = $dojo_data->owner($user_id);
    return undef unless $owner_data;
    return undef if $user_id != $owner_data->user_id;
    return undef if $dojo_id != $owner_data->dojo_id;

    return c->db->search_by_sql(
        'SELECT * FROM user_dojo_map JOIN user ON user_dojo_map.user_id = user.user_id WHERE user_dojo_map.dojo_id = ? AND status = 2',
        [ $dojo_id ],
    );
}

sub accept {
    my ($class, $user_id, $dojo_id, $accept_user_id) = @_;
    return undef unless $user_id; 
    return undef unless $dojo_id; 
    return undef unless $accept_user_id; 
    my $db = c->db;

    my $dojo_data = Grammatch::Model::Dojo->dojo($dojo_id);  
    return undef unless $dojo_data;
    my $owner_data = $dojo_data->owner($user_id);
    return undef unless $owner_data;
    return undef if $user_id != $owner_data->user_id;
    return undef if $dojo_id != $owner_data->dojo_id;

    my $accept_user_data = Grammatch::Model::User->user($accept_user_id);
    return undef unless $accept_user_data;

    return undef if $dojo_data->joined($accept_user_id) != 2;

    my $txn = $db->txn_scope;
    my $current_time = localtime();
    try {
        $db->update('user_dojo_map' => {
            status     => 1, # 入門中
            updated_at => $current_time,
        }, {
            user_id    => $accept_user_id,
            dojo_id    => $dojo_id,
        });
        $dojo_data->update({ dojo_member => $dojo_data->dojo_member + 1 });
        $txn->commit;
    } catch {
        $txn->rollback;
        die $_;
    };
    return 1;
}

1;
