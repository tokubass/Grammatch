package Grammatch::App::Search;
use strict;
use warnings;
use utf8;
use Amon2::Declare;   
use SQL::Maker::Select;
use Smart::Args;

sub dojo {
    args
        my $class,
        my $pref_id => { optional => 1 },
        my $keyword => { optional => 1 };
    
    my $stmt = SQL::Maker::Select->new();
    $stmt->add_join(dojo => { table => 'user', condition => 'dojo.user_id = user.user_id '});
    $stmt->add_where(dojo_summary => { like => '%'.$keyword.'%'}) if $keyword;
    $stmt->add_where('dojo.pref_id' => $pref_id) if $pref_id;
    $stmt->add_select('*');
    $stmt->add_select('dojo.pref_id' => 'dojo_pref_id');
    $stmt->add_order_by('dojo.dojo_id' => 'DESC');

    my $sql  = $stmt->as_sql();
    my @bind = $stmt->bind();
    return scalar c->db->search_by_sql($sql, [@bind]);
}

sub event {
    args
        my $class,
        my $pref_id => { optional => 1 },
        my $keyword => { optional => 1 };
    
    my $stmt = SQL::Maker::Select->new();
    $stmt->add_join(event => { table => 'dojo', condition => 'event.dojo_id = dojo.dojo_id '});
    $stmt->add_join(event => { table => 'user', condition => 'event.user_id = user.user_id '});
    $stmt->add_where(event_summary => { like => '%'.$keyword.'%'}) if $keyword;
    $stmt->add_where('event.pref_id' => $pref_id) if $pref_id;
    $stmt->add_select('*');
    $stmt->add_select('event.pref_id' => 'event_pref_id');
    $stmt->add_order_by('start_at' => 'DESC');

    my $sql  = $stmt->as_sql();
    my @bind = $stmt->bind();

    return scalar c->db->search_by_sql($sql, [@bind]);
}

1;
