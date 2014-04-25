package Grammatch::DB::Schema;
use strict;
use warnings;
use utf8;
use Teng::Schema::Declare;
use Time::Piece;

table {
    name 'user';
    pk   'id';

    columns qw/
        id user_name user_summary
        twitter_user_id twitter_screen_name
        pref_id allow_create_dojo
        last_logged_at created_at updated_at 
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
