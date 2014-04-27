package Grammatch::App::Search;
use strict;
use warnings;
use Amon2::Declare;   
use SQL::Maker::Condition;

sub dojo {
    my ($class, $pref_id, $keyword) = @_;

    my $condition = SQL::Maker::Condition->new();
    if ($keyword) {
        my @splited_keyword = split /\s/, $keyword;
        for (0 .. $#splited_keyword) {
            if ($_ == 0) {
                $condition->add(dojo_summary => {like => '%'.$splited_keyword[$_].'%'});
            } else {
                my $condition_keyword = SQL::Maker::Condition->new();
                $condition_keyword->add(dojo_summary => {like => '%'.$splited_keyword[$_].'%'});
                $condition = $condition | $condition_keyword;
            } 
        }
    }
    $condition = $condition->add('dojo.pref_id' => $pref_id) if $pref_id && $pref_id != 0;
    return c->db->search_by_sql(q{
        SELECT dojo.dojo_id as dojo_id, dojo_name, dojo_summary, dojo.pref_id as dojo_pref_id, user_name FROM dojo JOIN user ON dojo.user_id = user.user_id WHERE 
    } . $condition->as_sql, [ $condition->bind ], 'dojo');
}

1;
