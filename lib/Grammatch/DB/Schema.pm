package Grammatch::DB::Schema;
use strict;
use warnings;
use utf8;
use Teng::Schema::Declare;
use Time::Piece;

table {
    name 'user';
    pk   'user_id';
    columns qw/
        user_id dojo_id
        user_name user_summary
        twitter_user_id twitter_screen_name
        pref_id allow_create_dojo 
        last_logged_at created_at updated_at 
    /;

    inflate qr/_at$/ => sub { inflate_time(@_) };
    deflate qr/_at$/ => sub { deflate_time(@_) };
};

table {
    name 'dojo';
    pk   'dojo_id';
    columns qw/
        dojo_id user_id
        dojo_name dojo_summary dojo_member pref_id
        created_at updated_at
    /;

    inflate qr/_at$/ => sub { inflate_time(@_) };
    deflate qr/_at$/ => sub { deflate_time(@_) };
};

table {
    name 'user_dojo_map';
    pk   'id';
    columns qw/
        id user_id dojo_id
        status created_at updated_at
    /;
    # 0未登録, 1加入済み, 2加入申請中, 3師匠, 4免許皆伝
    row_class 'Grammatch::DB::Row::UserDojoMap';

    inflate qr/_at$/ => sub { inflate_time(@_) };
    deflate qr/_at$/ => sub { deflate_time(@_) };
};

table {
    name 'event';
    pk   'event_id';
    columns qw/
        event_id user_id event_id
        event_name event_member pref_id place reward period event_summary
        start_time created_at updated_at
    /;

    inflate qr/_at$/ => sub { inflate_time(@_) };
    deflate qr/_at$/ => sub { deflate_time(@_) };
    inflate 'start_time' => sub { inflate_time(@_) };
    deflate 'start_time' => sub { deflate_time(@_) };
};

table {
    name 'user_event_map';
    pk   'id';
    columns qw/
        id user_id event_id
        status created_at updated_at
    /;

    inflate qr/_at$/ => sub { inflate_time(@_) };
    deflate qr/_at$/ => sub { deflate_time(@_) };
};

sub inflate_time {
    my ($col_value) = shift;
    return localtime( $col_value );
}
sub deflate_time {
    my ($col_value) = @_;
    return ref $col_value eq 'Time::Piece' 
        ? $col_value->epoch 
        : die "Time::Piece obj only";
}

1;
