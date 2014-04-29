package Grammatch::Web::C::Search;
use strict;
use warnings;
use utf8;
use Grammatch::App::Search;

sub dojo {
    my ($class, $c) = @_;
    my $pref_id = $c->req->param('pref_id');
    my $keyword = $c->req->param('keyword');

    my $dojo_list = Grammatch::App::Search->dojo(pref_id => $pref_id, keyword => $keyword);
    return $c->render('dojo/search.tx', {
        pref_id   => $c->req->param('pref_id') || 0,
        keyword   => $c->req->param('keyword') || '',
        dojo_list => $dojo_list,
    });
}

sub event {
    my ($class, $c) = @_;
    my $pref_id = $c->req->param('pref_id');
    my $keyword = $c->req->param('keyword');

    my $event_list = Grammatch::App::Search->event(pref_id => $pref_id, keyword => $keyword);
    return $c->render('event/search.tx', {
        pref_id    => $c->req->param('pref_id') || 0,
        keyword    => $c->req->param('keyword') || '',
        event_list => $event_list,
    });
}

1;
