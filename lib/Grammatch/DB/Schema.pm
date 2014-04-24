package Grammatch::DB::Schema;
use strict;
use warnings;
use utf8;
use Teng::Schema::Declare;

table {
    name 'user';
    pk   'id';

    columns qw/
        id user_name user_summary
        twitter_user_id twitter_screen_name
        pref_id allow_create_dojo
        created_at updated_at 
    /;
};

1;
